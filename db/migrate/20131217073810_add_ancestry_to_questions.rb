class AddAncestryToQuestions < ActiveRecord::Migration
  def change
    add_column :question_categories, :ancestry, :string
    add_index :question_categories, :ancestry 
  end
end
