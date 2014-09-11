class QuestionPairingTranslation < ActiveRecord::Base
	belongs_to :question_pairing

  attr_accessible :question_pairing_id, :locale, :reference, :help_text,
                  :evidence1, :evidence2, :evidence3,
                  :evidence1_units, :evidence2_units, :evidence3_units,
                  :validation_equation, :validation_equation_wout_units, :validation_equation_units

end
