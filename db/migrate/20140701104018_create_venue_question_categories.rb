class CreateVenueQuestionCategories < ActiveRecord::Migration
  def change
    create_table :venue_question_categories do |t|
      t.integer :venue_id
      t.integer :question_category_id

      t.timestamps
    end
    
    add_index :venue_question_categories, :venue_id
    add_index :venue_question_categories, :question_category_id
  end
end
