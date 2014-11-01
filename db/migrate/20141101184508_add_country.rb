class AddCountry < ActiveRecord::Migration
  def change
    add_column :training_video_results, :country, :string
    add_column :training_video_results, :ip_address, :string
  end
end
