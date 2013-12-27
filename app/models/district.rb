class District < ActiveRecord::Base
	translates :name

	has_many :district_translations, :dependent => :destroy
	has_many :places
  accepts_nested_attributes_for :district_translations
  attr_accessible :id, :json, :district_translations_attributes
  
  validates :json, :presence => true
end
