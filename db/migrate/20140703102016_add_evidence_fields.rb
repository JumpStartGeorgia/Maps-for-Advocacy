class AddEvidenceFields < ActiveRecord::Migration
  def change
    rename_column :question_pairing_translations, :evidence, :evidence1    
    rename_column :place_evaluation_answers, :evidence, :evidence1    

    add_column :question_pairing_translations, :evidence1_units, :string, :limit => 10, after: :evidence1
    add_column :question_pairing_translations, :evidence2, :string, after: :evidence1_units    
    add_column :question_pairing_translations, :evidence2_units, :string, :limit => 10, after: :evidence2
    add_column :question_pairing_translations, :evidence3, :string, after: :evidence2_units
    add_column :question_pairing_translations, :evidence3_units, :string, :limit => 10, after: :evidence3

    add_column :place_evaluation_answers, :evidence2, :string, after: :evidence1    
    add_column :place_evaluation_answers, :evidence3, :string, after: :evidence2    
    add_column :place_evaluation_answers, :evidence_angle, :string, after: :evidence3
    
    add_column :question_pairings, :validation_equation, :string
    add_column :question_pairings, :validation_equation_wout_units, :string
    add_column :question_pairings, :validation_equation_units, :string, :limit => 10
    add_column :question_pairings, :is_evidence_angle, :boolean, :default => false
  end
end
