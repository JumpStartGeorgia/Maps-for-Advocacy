class MoveValidationFields < ActiveRecord::Migration
  def change
  	remove_column :question_pairings, :validation_equation
  	remove_column :question_pairings, :validation_equation_wout_units
  	remove_column :question_pairings, :validation_equation_units

  	add_column :question_pairing_translations, :validation_equation, :string
  	add_column :question_pairing_translations, :validation_equation_wout_units, :string
  	add_column :question_pairing_translations, :validation_equation_units, :string, :length => 10
  end
end
