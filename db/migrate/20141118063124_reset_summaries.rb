class ResetSummaries < ActiveRecord::Migration
  def up
    PlaceSummary.reset_all_place_summaries
  end

  def down
    # do nothing
  end
end
