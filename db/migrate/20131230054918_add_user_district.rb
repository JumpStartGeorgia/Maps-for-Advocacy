class AddUserDistrict < ActiveRecord::Migration
  def up
    add_column :users, :district_id, :integer
    
    # if users have coordinates, assign district id
    User.where('lat is not null and lon is not null').each do |user|
      user.assign_district(true)
    end
  end

  def down
    remove_column :users, :district_id
  end
end
