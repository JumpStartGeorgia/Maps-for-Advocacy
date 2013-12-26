class CreateDisabilities < ActiveRecord::Migration
  def up
    create_table :disabilities do |t|
      t.string :code

      t.timestamps
    end

    Disability.create_translation_table! :name => :string
    add_index :disability_translations, :name


    # add disability id to place evaluation
    add_column :place_evaluations, :disability_id, :integer
    add_index :place_evaluations, :disability_id

    # create question pairing/disability habtm table
    create_table :disabilities_question_pairings, :id => false do |t|
      t.integer :disability_id
      t.integer :question_pairing_id
    end    
    add_index :disabilities_question_pairings, :disability_id
    add_index :disabilities_question_pairings, :question_pairing_id


  end
  
  def down
    drop_table :disabilities
    Disability.drop_translation_table!

    remove_index :place_evaluations, :disability_id
    remove_column :place_evaluations, :disability_id
   
    drop_table :disabilities_question_pairings
  end

end
