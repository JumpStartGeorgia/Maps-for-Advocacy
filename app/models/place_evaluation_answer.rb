class PlaceEvaluationAnswer < ActiveRecord::Base

  belongs_to :place_evaluation
  belongs_to :question_pairing

  attr_accessible :place_evaluation_id, :question_pairing_id, :answer, :evidence, :evidence1, :evidence2, :old_user_id, :old_place_id
  attr_accessor :evidence1, :evidence2
  
  validates :question_pairing_id, :answer, :presence => true

  before_save :populate_evidence
  before_save :populate_answer
  
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

    
end
