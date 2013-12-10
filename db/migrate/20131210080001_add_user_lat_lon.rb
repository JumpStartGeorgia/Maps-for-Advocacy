class AddUserLatLon < ActiveRecord::Migration
  def change
    add_column :users, :lat, :decimal, :precision => 15, :scale => 12, :default => nil 
    add_column :users, :lon, :decimal, :precision => 15, :scale => 12, :default => nil
  end
end
