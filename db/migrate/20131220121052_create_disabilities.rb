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

    # create question disability habtm table
    create_table :disabilities_questions, :id => false do |t|
      t.integer :disability_id
      t.integer :question_id
    end    
    add_index :disabilities_questions, :disability_id
    add_index :disabilities_questions, :question_id


  end
  
  def down
    drop_table :disability
    Disability.drop_translation_table!

    remove_index :place_evaluations, :disability_id
    remove_column :place_evaluations, :disability_id
   
    drop_table :disabilities_questions 
  end

end
