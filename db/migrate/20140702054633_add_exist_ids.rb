class AddExistIds < ActiveRecord::Migration
  def change
    add_column :question_pairings, :exists_id, :integer, :limit => 2
    add_column :question_pairings, :exists_parent_id, :integer, :limit => 2
  end
end
