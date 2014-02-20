class AddSummaryCertified < ActiveRecord::Migration
  def change
    add_column :place_summaries, :is_certified, :boolean, :default => false
    add_index :place_summaries, :is_certified
  end
end
