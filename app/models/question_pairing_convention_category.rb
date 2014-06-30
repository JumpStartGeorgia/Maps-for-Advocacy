class QuestionPairingConventionCategory < ActiveRecord::Base
	belongs_to :question_pairing
	belongs_to :convention_category
  attr_accessible :question_pairing_id, :convention_category_id

  validates :question_pairing_id, :convention_category_id, :presence => true

end
