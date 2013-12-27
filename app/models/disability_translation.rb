class DisabilityTranslation < ActiveRecord::Base
	belongs_to :disability

  attr_accessible :disability_id, :name, :locale

  validates :name, :presence => true

  def required_data_provided?
    provided = false
    
    provided = self.name.present?
    
    return provided
  end
  
  def add_required_data(obj)
    self.name = obj.name if self.name.blank?
  end

end
