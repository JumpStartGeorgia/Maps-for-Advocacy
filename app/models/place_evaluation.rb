class PlaceEvaluation < ActiveRecord::Base

  belongs_to :place
  belongs_to :user
  has_many :place_evaluation_answers, :dependent => :destroy
  accepts_nested_attributes_for :place_evaluation_answers
  attr_accessible :place_id, :user_id, :place_evaluation_answers_attributes, :created_at
  validates :user_id, :presence => true

  
  ANSWERS = {'no_answer' => 0, 'not_relevant' => 1, 'needs' => 2, 'has_bad' => 3, 'has_good' => 4}
  
  def self.answer_key_name(value)
    ANSWERS.keys[ANSWERS.values.index(value)]
  end
  
  def self.with_answers(place_id)
    includes(:place_evaluation_answers)
    .where(:place_id => place_id)  
  end
  
  def self.sorted
    order('place_evaluations.created_at desc, place_evaluations.user_id asc')
  end
  

  # create a summary of the evaluation results
  # create summary for each evaluation and then an overall summary
  def self.summarize(evaluations, questions)
    summary = Hash.new
    summary['overall'] = Hash.new
    summary['evaluations'] = []
  
    if evaluations.present? && questions.present?
      # get unique question category ids
      category_ids = questions.map{|x| x.id}.uniq
      
      evaluations.each do |evaluation|
        # create evaluation summaries
        evaluation_summary = Hash.new
        summary['evaluations'] << evaluation_summary

        evaluation_summary['id'] = evaluation.id

        records = evaluation.place_evaluation_answers

        # - overall of all answers for this evaluation
        answers = records.map{|x| x.answer}
        avg = answers.sum / answers.size.to_f
        evaluation_summary['overall'] = avg

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
            
            # add to evaluation record
            evaluation_summary[category_id.to_s] = avg
          end
        end      

        # create overall summary
        # - overall of all answers
        answers = evaluations.map{|x| x.place_evaluation_answers.map{|x| x.answer}}.flatten
        avg = answers.sum / answers.size.to_f
        summary['overall']['overall'] = avg
        
        # - by category
        category_ids.each do |category_id|
          question_pairing_ids = questions.select{|x| x.id == category_id}.map{|x| x['question_pairing_id']}
          if question_pairing_ids.present?
            evals = []
            # get evaluation records that match
            question_pairing_ids.each do |qp_id|
              evals << evaluations.map{|x| x.place_evaluation_answers.select{|x| x.question_pairing_id == qp_id}}
            end
            evals.flatten!
            
            # average the answers
            answers = evals.map{|x| x.answer}
            avg = answers.sum / answers.size.to_f
            
            # add to overall record
            summary['overall'][category_id.to_s] = avg
          end
        end
      end
    end
Rails.logger.debug "*************** summary = #{summary}"  
    return summary
  end

    
end
