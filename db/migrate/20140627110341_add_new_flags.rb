class AddNewFlags < ActiveRecord::Migration
  def up
    add_column :question_pairings, :is_domestic_legal_requirement, :boolean, :default => false
    add_column :question_pairings, :convention_category_id, :integer
    add_index :question_pairings, :is_domestic_legal_requirement 
    add_index :question_pairings, :convention_category_id

    add_column :question_pairing_translations, :reference, :string
    add_column :question_pairing_translations, :help_text, :text

  end

  def down
    remove_index :question_pairings, :is_domestic_legal_requirement 
    remove_index :question_pairings, :convention_category_id
    remove_column :question_pairings, :is_domestic_legal_requirement
    remove_column :question_pairings, :convention_category_id

    remove_column :question_pairing_translations, :reference
    remove_column :question_pairing_translations, :help_text
  end
end
