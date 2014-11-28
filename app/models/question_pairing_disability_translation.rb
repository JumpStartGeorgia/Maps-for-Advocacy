class QuestionPairingDisabilityTranslation < ActiveRecord::Base
  belongs_to :quesiton_pairing_disability

  attr_accessible :question_pairing_disability_id, :content, :locale

  validates :content, :presence => true

  before_validation :bf
  after_validation :af
  before_save :testing1
  after_save :testing2
  before_create :bc
  after_create :ac

  def bf
    logger.debug "@@@@@@@@@!!!! before validate qpdt"
  end
  def af
    logger.debug "@@@@@@@@@!!!! after validate qpdt"
  end
  def bc
    logger.debug "@@@@@@@@@!!!! before create qpd"
  end
  def ac
    logger.debug "@@@@@@@@@!!!! after create qpd"
  end
  def testing1
    logger.debug "@@@@@@@@@!!!! before save qpdt"
  end
  
  def testing2
    logger.debug "@@@@@@@@@!!!! after save qpdt"
  end




  
  def required_data_provided?
    provided = false
    
    provided = self.content.present?
    
    return provided
  end
  
  def add_required_data(obj)
    self.content = obj.content if self.content.blank?
  end

end
