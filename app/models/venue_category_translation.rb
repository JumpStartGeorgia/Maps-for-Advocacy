class VenueCategoryTranslation < ActiveRecord::Base
	belongs_to :venue_category

  attr_accessible :venue_category_id, :name, :locale

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
