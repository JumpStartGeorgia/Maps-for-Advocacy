class CreateDistricts < ActiveRecord::Migration
  def up
    create_table :districts do |t|
      t.text :json, :limit => 2147483647

      t.timestamps
    end
    
    District.create_translation_table! :name => :string
  end
  
  def down
    drop_table :districts
    District.drop_translation_table!
  end

end
