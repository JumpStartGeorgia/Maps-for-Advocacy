class AddDisActiveFlag < ActiveRecord::Migration
  def up
    remove_index :disabilities, :active
    remove_column :disabilities, :active
    
    add_column :disabilities, :active_public, :boolean, :default => true
    add_column :disabilities, :active_certified, :boolean, :default => true
    add_index :disabilities, :active_public
    add_index :disabilities, :active_certified
    
    add_column :disabilities, :sort_order, :integer, :limit => 1, :default => 1
    add_index :disabilities, :sort_order
  end

  def down
    add_column :disabilities, :active, :boolean, :default => true
    add_index :disabilities, :active

    remove_index :disabilities, :active_public
    remove_index :disabilities, :active_certified
    remove_column :disabilities, :active_public
    remove_column :disabilities, :active_certified

    remove_index :disabilities, :sort_order
    remove_column :disabilities, :sort_order
  end
end
