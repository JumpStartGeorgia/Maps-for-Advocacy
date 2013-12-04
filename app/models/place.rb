class Place < ActiveRecord::Base
	translates :name

  belongs_to :venue
	has_many :place_translations, :dependent => :destroy
	has_many :place_evaluations, :dependent => :destroy
  accepts_nested_attributes_for :place_translations
  accepts_nested_attributes_for :place_evaluations
  attr_accessible :venue_id, :district_id, :lat, :lon, :place_translations_attributes, :place_evaluations_attributes
  
  validates :venue_id, :lat, :lon, :presence => true
  

end
