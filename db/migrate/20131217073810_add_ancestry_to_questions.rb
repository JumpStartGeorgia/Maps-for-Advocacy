class AddAncestryToQuestions < ActiveRecord::Migration
  def change
    add_column :questions, :ancestry, :string
    add_index :questions, :ancestry 
  end
end
