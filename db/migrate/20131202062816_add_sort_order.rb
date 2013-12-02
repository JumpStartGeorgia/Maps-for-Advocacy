class AddSortOrder < ActiveRecord::Migration
  def up
    add_column :question_categories, :sort_order, :integer, :default => 99
    add_index :question_categories, :sort_order

    add_column :question_pairings, :sort_order, :integer, :default => 99
    add_index :question_pairings, :sort_order
  end

  def down
    remove_index :question_categories, :sort_order
    remove_column :question_categories, :sort_order

    remove_index :question_pairings, :sort_order
    remove_column :question_pairings, :sort_order
  end
end
