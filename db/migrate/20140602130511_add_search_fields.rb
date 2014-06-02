class AddSearchFields < ActiveRecord::Migration
  def up
    add_column :place_translations, :search_name, :string
    add_column :place_translations, :search_address, :string
    
    add_index :place_translations, :search_name 
    add_index :place_translations, :search_address
    
    PlaceTranslation.transaction do 
      PlaceTranslation.all.each do |pt|
        pt.clean_text(true)
        pt.save
      end
    end
  end

  def down
    remove_index :place_translations, :search_name 
    remove_index :place_translations, :search_address

    remove_column :place_translations, :search_name
    remove_column :place_translations, :search_address
  end
end
