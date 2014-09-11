class AddUniqueIdFields < ActiveRecord::Migration
  def change
  	add_column :venue_categories, :unique_id, :integer
  	add_column :venues, :unique_id, :integer
  	add_column :question_categories, :unique_id, :string, :length => 8
  	add_column :questions, :unique_id, :integer
    add_column :question_pairings, :unique_id, :integer

  	add_index :venue_categories, :unique_id
  	add_index :venues, :unique_id
  	add_index :question_categories, :unique_id
  	add_index :questions, :unique_id
    add_index :question_pairings, :unique_id
  end

end
