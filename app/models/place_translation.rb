class PlaceTranslation < ActiveRecord::Base
	belongs_to :place

  attr_accessible :place_category_id, :name, :locale, :address, :search_name, :search_address

  validates :name, :address, :presence => true
  
  before_save :clean_text

  # if this is not ka locale and name/address have geo text, latinize it
  def clean_text(force_clean=false)
    if self.name_changed? || force_clean
      self.name = self.name.strip
    
      if self.locale != 'ka'
        self.name = self.name.latinize.titlecase if self.name.is_georgian?
      end
      
      self.search_name = self.name.latinize.to_ascii.downcase
    end
    
    if self.address_changed? || force_clean
      self.address = self.address.strip
    
      if self.locale != 'ka'
        self.address = self.address.latinize.titlecase if self.address.is_georgian?
      end

      self.search_address = self.address.latinize.to_ascii.downcase
    end
    
  end
  
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
