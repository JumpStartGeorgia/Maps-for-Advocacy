class QuestionPairing < ActiveRecord::Base
	translates :evidence

	belongs_to :question_category
	belongs_to :question
  attr_accessible :id, :question_category_id, :question_id
end
