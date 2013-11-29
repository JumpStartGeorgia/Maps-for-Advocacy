class CreateQuestionPairings < ActiveRecord::Migration
  def up
    create_table :question_pairings do |t|
      t.integer :question_category_id
      t.integer :question_id

      t.timestamps
    end
    add_index :question_pairings, [:question_category_id, :question_id], :name => 'idx_pairings_ids'
    
    QuestionPairing.create_translation_table! :evidence => :string
  end
  
  def down
    drop_table :question_pairings
    QuestionPairing.drop_translation_table!
  end
end
