class CreatePlaceImages < ActiveRecord::Migration
  def up
    create_table :place_images do |t|
      t.integer :place_id

      t.timestamps
    end
    add_index :place_images, :place_id
    
    add_attachment :place_images, :image
  end
  
  def down
    drop_table :place_images
  end
end
