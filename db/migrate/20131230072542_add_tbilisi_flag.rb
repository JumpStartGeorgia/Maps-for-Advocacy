class AddTbilisiFlag < ActiveRecord::Migration
  def up
    add_column :districts, :in_tbilisi, :boolean, :default => false
    add_index :districts, :in_tbilisi 

    # mark the first 10 districts as in tbilisi
    District.where(:id => 1..10).update_all(:in_tbilisi => true)
  end

  def down
    remove_column :districts, :in_tbilisi
    remove_index :districts, :in_tbilisi 
  end
end
