class QuestionPairing < ActiveRecord::Base
	translates :evidence

	belongs_to :question_category
	belongs_to :question
	has_many :question_pairing_translations, :dependent => :destroy
  accepts_nested_attributes_for :question_pairing_translations
  attr_accessible :id, :question_category_id, :question_id, :question_pairing_translations_attributes, :sort_order
end
