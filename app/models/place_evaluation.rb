class PlaceEvaluation < ActiveRecord::Base

  belongs_to :place
  belongs_to :user
  belongs_to :disability
  has_many :place_evaluation_answers, :dependent => :destroy
  accepts_nested_attributes_for :place_evaluation_answers
  attr_accessible :place_id, :user_id, :place_evaluation_answers_attributes, :created_at, :disability_id
  validates :user_id, :disability_id, :presence => true

  
  ANSWERS = {'no_answer' => 0, 'not_relevant' => 1, 'needs' => 2, 'has_bad' => 3, 'has_good' => 4, 'has' => 5}
  SUMMARY_ANSWERS = {'not_accessible' => 0, 'no_answer' => 1, 'not_relevant' => 2}
  
  def self.answer_key_name(value)
    ANSWERS.keys[ANSWERS.values.index(value)]
  end
  
  def self.summary_answer_key_name(value)
    SUMMARY_ANSWERS.keys[SUMMARY_ANSWERS.values.index(value)]
  end
  
  def self.with_answers(place_id, disability_id=nil)
    includes(:place_evaluation_answers)
    .where(:place_id => place_id)  
    .where(:disability_id => disability_id) if disability_id.present?
  end
  
  def self.sorted
    order('place_evaluations.created_at desc, place_evaluations.user_id asc')
  end
  

  # create a summary of the evaluation results
  # create summary for each evaluation and then an overall summary
  # return: {
  #  'overall' => {overall => {score, special_flag}, cat_id1 => {score, special_flag}, cat_id2, etc},
  #  'evaluations' => [{id, overall => {score, special_flag}, cat_id1 => {score, special_flag}, cat_id2, etc},etc]  
  # }
  def self.summarize(evaluations, question_categories)
    summary = Hash.new
    summary['overall'] = Hash.new
    summary['overall']['overall'] = Hash.new
    summary['evaluations'] = []
  
    questions = organize_questions(question_categories)
    
    if evaluations.present? && questions.present?
      
      all_answers = evaluations.map{|x| x.place_evaluation_answers}.flatten
      category_ids = questions.map{|x| x[:category_id]}.uniq
      exists_question_ids = questions.select{|x| x[:is_exists] == 1}.map{|x| x[:question_pairing_id]}
      req_accessibility_question_ids = questions.select{|x| x[:required_for_accessibility] == 1}.map{|x| x[:question_pairing_id]}

      #############################################
      # compute overall evaluation
      #############################################
      summary['overall']['overall'] = summarize_answers(all_answers, exists_question_ids, req_accessibility_question_ids)
      
      #############################################
      # process each evaluation
      #############################################
      evaluations.each do |evaluation|
        # create evaluation summaries
        evaluation_summary = Hash.new
        summary['evaluations'] << evaluation_summary

        evaluation_summary['id'] = evaluation.id
        evaluation_summary['overall'] = Hash.new

        records = evaluation.place_evaluation_answers

        #############################################
        # overall of all answers for this evaluation
        #############################################
        evaluation_summary['overall'] = summarize_answers(records, exists_question_ids, req_accessibility_question_ids)

        #############################################
        # for each category, get answers            
        #############################################
        category_ids.each do |category_id|
          question_pairing_ids = questions.select{|x| x[:category_id] == category_id}.map{|x| x[:question_pairing_id]}
          if question_pairing_ids.present?
            
            #### for all evaluations
            # get evaluation records that match
            evals = all_answers.select{|x| question_pairing_ids.index(x.question_pairing_id).present? }
            
            # add to evaluation record
            summary['overall'][category_id.to_s] = Hash.new
            summary['overall'][category_id.to_s] = summarize_answers(evals, exists_question_ids, req_accessibility_question_ids)

            #### for this evaluation
            # get evaluation records that match
            evals = records.select{|x| question_pairing_ids.index(x.question_pairing_id).present? }
            
            # add to evaluation record
            evaluation_summary[category_id.to_s] = Hash.new
            evaluation_summary[category_id.to_s] = summarize_answers(evals, exists_question_ids, req_accessibility_question_ids)
          end
        end      
      end
      
      
    end
  
    Rails.logger.debug "*************** summary = #{summary}"  
    return summary
  end

    
    
private
  ## return 1-d array of all questions with their category and pairing id
  ## [{:category_id, :question_pairing_id, :is_exists, :required_for_accessibility}]
  def self.organize_questions(question_categories, category_id=nil)
    categories = []
    if question_categories.present?
      question_categories.each do |cat|
        cat_id = category_id.present? ? category_id : cat.id
        categories << cat[:questions].map{
          |x| {:category_id => cat_id, :question_pairing_id => x['question_pairing_id'],
               :is_exists => x['is_exists'], :required_for_accessibility => x['required_for_accessibility'] } 
        }
        # if there are subcategories get the questions from those too
        if cat[:sub_categories].present?
          categories << organize_questions(cat[:sub_categories], cat_id)
        end
      end
    end
    return categories.flatten!
  end    
  
  # records: array of place_evaluation_answers
  # exists_questions_ids: array of ids to questions that have exists flag
  # req_accessibility_question_ids: array of ids to questions that have required for accessibility flag
  # returns: [score, special_flag]
  # - score = overall average of records passed in unless a special case was found
  # - special_flag = one of SUMMARY_ANSWERS values or nil; will be nil if score has value
  def self.summarize_answers(records, exists_question_ids, req_accessibility_question_ids)
    h = {'score' => nil, 'special_flag' => nil, 'num_answers' => nil, 'num_evaluations' => nil}
    
    if records.present?
      h['num_evaluations'] = records.map{|x| x.place_evaluation_id}.uniq.length
      h['num_answers'] = records.select{|x| x.answer > ANSWERS['no_answer']}.length

      results = records.map{|x| [x.question_pairing_id, x.answer]}
      # see if any required accessibility questions have 'needs' answer
      if req_accessibility_question_ids.present? && results.index{|x| req_accessibility_question_ids.index(x[0]).present? && x[1] == ANSWERS['needs']}.present?
#        Rails.logger.debug "************ found an answer that is 'needs' for a required accessibility question -> not accessible"
        # found an answer that is 'needs' for a required accessibility question
        # -> not accessible
        h['special_flag'] = SUMMARY_ANSWERS['not_accessible']
      else
        # get average of answers that are not:
        # - for exists questions 
        # - do not have answers of not relevant or not answerd
        filtered_results = results.select{|x| (exists_question_ids.nil? || exists_question_ids.index(x[0]).nil?) && [ANSWERS['no_answer'], ANSWERS['not_relevant']].index(x[1]).nil?}
        if filtered_results.present?
          answers = filtered_results.map{|x| x[1]}
          avg = answers.sum / answers.size.to_f
          h['score'] = avg
        else
          if results.select{|x| x[1] == ANSWERS['not_relevant']}.present?
#            Rails.logger.debug "************ has not relevant only answers"
            h['special_flag'] = SUMMARY_ANSWERS['not_relevant']
          else
#            Rails.logger.debug "************ has no answers"
            h['special_flag'] = SUMMARY_ANSWERS['no_answer']
          end
        end        
      end
    end

    return h
  end
end
