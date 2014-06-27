class AddRightAccessFlag < ActiveRecord::Migration
  def change
    add_column :convention_categories, :right_to_accessibility, :boolean, :default => false
    add_index :convention_categories, :right_to_accessibility
  end
end
