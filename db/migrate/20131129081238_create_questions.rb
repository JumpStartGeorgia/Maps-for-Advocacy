class CreateQuestions < ActiveRecord::Migration
  def up
    create_table :questions do |t|

      t.timestamps
    end
    
    Question.create_translation_table! :name => :string
  end
  
  def down
    drop_table :questions
    Question.drop_translation_table!
  
  end
end
