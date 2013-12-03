class CreatePlaces < ActiveRecord::Migration
  def up
    create_table :places do |t|
      t.integer :venue_id
      t.integer :district_id
      t.decimal :lat, :precision => 15, :scale => 12
      t.decimal :lon, :precision => 15, :scale => 12

      t.timestamps
    end

    add_index :places, :venue_id
    add_index :places, :district_id
    
    Place.create_translation_table! :name => :string
  end
  
  def down
    drop_table :places
    Place.drop_translation_table!
  end
end
