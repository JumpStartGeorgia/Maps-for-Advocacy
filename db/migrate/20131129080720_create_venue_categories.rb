class CreateVenueCategories < ActiveRecord::Migration
  def up
    create_table :venue_categories do |t|

      t.timestamps
    end
    
    VenueCategory.create_translation_table! :name => :string
  end
  
  def down
    drop_table :venue_categories
    VenueCategory.drop_translation_table!
  
  end
end
