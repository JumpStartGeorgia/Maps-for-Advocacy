class CreateVenueRights < ActiveRecord::Migration
  def change
    create_table :venue_rights do |t|
      t.integer :venue_id
      t.integer :right_id

      t.timestamps
    end
    add_index :venue_rights, :venue_id
    add_index :venue_rights, :right_id
  end
end
