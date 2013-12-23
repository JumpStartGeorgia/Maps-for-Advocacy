class Disability < ActiveRecord::Base
	translates :name

	has_many :disability_translations, :dependent => :destroy
	has_many :place_evalations
  has_and_belongs_to_many :questions
  accepts_nested_attributes_for :disability_translations
  attr_accessible :code, :disability_translations_attributes
  
  validates :code, :presence => true


end
