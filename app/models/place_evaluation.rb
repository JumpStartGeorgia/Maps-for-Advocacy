class PlaceEvaluation < ActiveRecord::Base

  belongs_to :place
  belongs_to :question_pairing

  attr_accessible :place_id, :user_id, :question_pairing_id, :answer, :evidence, :evidence1, :evidence2
  attr_accessor :evidence1, :evidence2
  
  validates :user_id, :question_pairing_id, :answer, :presence => true

  before_save :populate_evidence
  
  
  # evaluation form has two evidence textboxes
  # if one has value, set evidence to this value
  def populate_evidence
    self.evidence = read_attribute(:evidence1) if read_attribute(:evidence1).present?
    self.evidence = read_attribute(:evidence2) if read_attribute(:evidence2).present?
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
