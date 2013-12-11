class AddDefaultAnswer < ActiveRecord::Migration
  def up
    change_column :place_evaluations, :answer, :integer, :default => 0
  end

  def down
    change_column :place_evaluations, :answer, :integer, :default => nil
  end
end
