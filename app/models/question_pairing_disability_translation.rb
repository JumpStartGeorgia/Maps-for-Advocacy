class QuestionPairingDisabilityTranslation < ActiveRecord::Base
  belongs_to :quesiton_pairing_disability

  attr_accessible :question_pairing_disability_id, :content, :locale

  validates :content, :presence => true
  
  def required_data_provided?
    provided = false
    
    provided = self.content.present?
    
    return provided
  end
  
  def add_required_data(obj)
    self.content = obj.content if self.content.blank?
  end

end
