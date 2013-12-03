class Place < ActiveRecord::Base
	translates :name

  has_one :venue
	has_many :place_translations, :dependent => :destroy
  accepts_nested_attributes_for :place_translations
  attr_accessible :venue_id, :district_id, :lat, :lon, :place_translations_attributes
  
  validates :venue_id, :lat, :lon, :presence => true
  

end
