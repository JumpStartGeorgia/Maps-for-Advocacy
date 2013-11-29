class Question < ActiveRecord::Base
	translates :name

	has_many :question_translations, :dependent => :destroy
  has_many :question_pairings, :dependent => :destroy
  accepts_nested_attributes_for :question_translations
  accepts_nested_attributes_for :question_pairings
  attr_accessible :id, :question_translations_attributes, :question_pairings_attributes
end
