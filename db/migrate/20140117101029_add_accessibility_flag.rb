class AddAccessibilityFlag < ActiveRecord::Migration
  def change
    add_column :question_pairings, :required_for_accessibility, :boolean, :default => false
    add_index :question_pairings, :required_for_accessibility 
  end
end
