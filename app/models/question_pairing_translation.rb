class QuestionPairingTranslation < ActiveRecord::Base
	belongs_to :question_pairing

  attr_accessible :question_pairing_id, :evidence, :locale

end
