class AddVenueSort < ActiveRecord::Migration
  def up
    add_column :venue_categories, :sort_order, :integer, :default => 99
    add_index :venue_categories, :sort_order

    add_column :venues, :sort_order, :integer, :default => 99
    add_index :venues, :sort_order
  end

  def down
    remove_index :venue_categories, :sort_order
    remove_column :venue_categories, :sort_order

    remove_index :venues, :sort_order
    remove_column :venues, :sort_order
  end
end
