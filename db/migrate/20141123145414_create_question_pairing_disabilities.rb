class CreateQuestionPairingDisabilities < ActiveRecord::Migration
  def up
    create_table :question_pairing_disabilities do |t|
      t.integer :question_pairing_id
      t.integer :disability_id
      t.boolean :has_content, :default => false

      t.timestamps
    end
    add_index :question_pairing_disabilities, [:question_pairing_id, :disability_id, :has_content], :name => 'idx_qpd_content'

    QuestionPairingDisability.create_translation_table! :content => :text
  end

  def down
    drop_table :question_pairing_disabilities
    QuestionPairingDisability.drop_translation_table!
  end
end
