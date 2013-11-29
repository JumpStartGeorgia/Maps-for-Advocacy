class CreateQuestionCategories < ActiveRecord::Migration
  def up
    create_table :question_categories do |t|
      t.boolean :is_common, :default => false

      t.timestamps
    end
    add_index :question_categories, :is_common
    
    QuestionCategory.create_translation_table! :name => :string
  end
  
  def down
    drop_table :question_categories
    QuestionCategory.drop_translation_table!
  
  end
end
