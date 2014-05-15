class AddPublicSummaryFields < ActiveRecord::Migration
  def change
    add_column :place_summaries, :percentage, :decimal, :precision => 5, :scale => 2    
    add_column :place_summaries, :num_yes, :integer
    add_column :place_summaries, :num_no, :integer
  end
end
