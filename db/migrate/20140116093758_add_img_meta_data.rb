class AddImgMetaData < ActiveRecord::Migration
  def up  
    add_column :place_images, :user_id, :integer
    add_index :place_images, :user_id  
    
    add_column :place_images, :taken_at, :datetime
    add_index :place_images, :taken_at
    
  end

  def down
    remove_index :place_images, :user_id  
    remove_column :place_images, :user_id
    
    remove_index :place_images, :taken_at
    remove_column :place_images, :taken_at
  end
end
