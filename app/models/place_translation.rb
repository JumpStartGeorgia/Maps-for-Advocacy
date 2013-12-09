class PlaceTranslation < ActiveRecord::Base
	belongs_to :place_category

  attr_accessible :place_category_id, :name, :locale, :address

  validates :name, :address, :presence => true

  def required_data_provided?
    provided = false
    
    provided = self.name.present? && self.address.present?
    
    return provided
  end
  
  def add_required_data(obj)
    self.name = obj.name if self.name.blank?
    self.address = obj.address if self.address.blank?
  end

end
