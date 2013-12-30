class AddExistsFlag < ActiveRecord::Migration
  def change
    add_column :question_pairings, :is_exists, :boolean, :default => false
  end
end
