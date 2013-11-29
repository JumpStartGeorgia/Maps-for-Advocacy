class Venue < ActiveRecord::Base
	translates :name

	belongs_to :question_category
	belongs_to :venue_category
	has_many :venue_translations, :dependent => :destroy
  accepts_nested_attributes_for :venue_translations
  attr_accessible :id, :venue_category_id, :question_category_id, :venue_translations_attributes
end
