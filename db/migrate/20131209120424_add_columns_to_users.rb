class AddColumnsToUsers < ActiveRecord::Migration
  def up
    add_column :users, :provider, :string
    add_column :users, :uid, :string
    add_column :users, :nickname, :string
    add_column :users, :avatar, :string
    
    User.transaction do
      User.all.each do |user|
        if user.nickname.blank?
          user.nickname = user.email.split('@')[0]
          user.save
        end
      end
    end
  end
  
  def down
    remove_column :users, :provider, :string
    remove_column :users, :uid, :string
    remove_column :users, :nickname, :string
    remove_column :users, :avatar, :string
  end
end
