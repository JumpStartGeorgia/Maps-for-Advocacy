class VenueTranslation < ActiveRecord::Base
	belongs_to :venue

  attr_accessible :venue_id, :name, :locale

  validates :name, :presence => true
  
  def required_data_provided?
    provided = false
    
    provided = self.name.present?
    
    return provided
  end
  
  def add_required_data(obj)
    self.name = obj.name
  end
  

end
