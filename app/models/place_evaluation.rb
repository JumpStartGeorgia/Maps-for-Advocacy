class PlaceEvaluation < ActiveRecord::Base

  belongs_to :place
  belongs_to :question_pairing

  attr_accessible :place_id, :user_id, :question_pairing_id, :answer, :evidence, :evidence1, :evidence2
  attr_accessor :evidence1, :evidence2
  
  validates :user_id, :question_pairing_id, :answer, :presence => true

  before_save :populate_evidence
  before_save :populate_answer
  
  ANSWERS = {'no_answer' => 0, 'not_relevant' => 1, 'needs' => 2, 'has_bad' => 3, 'has_good' => 4}
  
  def self.answer_key_name(value)
    ANSWERS.keys[ANSWERS.values.index(value)]
  end
  
  # evaluation form has two evidence textboxes
  # if one has value, set evidence to this value
  def populate_evidence
    self.evidence = read_attribute(:evidence1) if read_attribute(:evidence1).present?
    self.evidence = read_attribute(:evidence2) if read_attribute(:evidence2).present?
  end

  # if there is no answer, default it to no-answer
  def populate_answer
    self.answer = ANSWERS['no_answer'] if read_attribute(:answer).blank?
  end

  def evidence1=(text)
    write_attribute(:evidence1, text)
  end
  
  def evidence2=(text)
    write_attribute(:evidence2, text)
  end
  
  def evidence1
    if read_attribute(:evidence1).present?
      read_attribute(:evidence1)
    else
      read_attribute(:evidence)
    end
  end
    
  def evidence2
    if read_attribute(:evidence2).present?
      read_attribute(:evidence2)
    else
      read_attribute(:evidence)
    end
  end


  def self.sorted
    order('created_at desc, user_id asc, question_pairing_id asc')
  end
  

  # create a summary of the evaluation results
  # create summary for each user and then an overall summary
  def self.summarize(evaluations, questions)
    summary = Hash.new
    summary['overall'] = Hash.new
    summary['users'] = []
  
    if evaluations.present? && questions.present?
      # get unique user ids
      user_ids = evaluations.map{|x| x.user_id}.uniq
      # get unique question category ids
      category_ids = questions.map{|x| x.id}.uniq
      
      if user_ids.present?
        # create user summaries
        user_ids.each do |user_id|

          user_summary = Hash.new
          summary['users'] << user_summary

          user_summary['id'] = user_id

          records = evaluations.select{|x| x.user_id == user_id}

          # for each category, get answers            
          category_ids.each do |category_id|
            question_pairing_ids = questions.select{|x| x.id == category_id}.map{|x| x['question_pairing_id']}
            if question_pairing_ids.present?
              evals = []
              # get evaluation records that match
              question_pairing_ids.each do |qp_id|
                evals << records.select{|x| x.question_pairing_id == qp_id}
              end
              evals.flatten!
              
              # average the answers
              answers = evals.map{|x| x.answer}
              avg = answers.sum / answers.size.to_f
              
              # add to user record
              user_summary[category_id.to_s] = avg
            end
          end

        end      

        # create overall summary
        category_ids.each do |category_id|
          question_pairing_ids = questions.select{|x| x.id == category_id}.map{|x| x['question_pairing_id']}
          if question_pairing_ids.present?
            evals = []
            # get evaluation records that match
            question_pairing_ids.each do |qp_id|
              evals << evaluations.select{|x| x.question_pairing_id == qp_id}
            end
            evals.flatten!
            
            # average the answers
            answers = evals.map{|x| x.answer}
            avg = answers.sum / answers.size.to_f
            
            # add to user record
            summary['overall'][category_id.to_s] = avg
          end
        end
      end
    end
Rails.logger.debug "*************** summary = #{summary}"  
    return summary
  end

    
end
