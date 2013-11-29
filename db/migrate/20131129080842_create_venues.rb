class CreateVenues < ActiveRecord::Migration
  def up
    create_table :venues do |t|
      t.integer :venue_category_id
      t.integer :question_category_id

      t.timestamps
    end
    add_index :venues, :venue_category_id
    add_index :venues, :question_category_id
    
    Venue.create_translation_table! :name => :string
  end
  
  def down
    drop_table :venues
    Venue.drop_translation_table!
  end

end
