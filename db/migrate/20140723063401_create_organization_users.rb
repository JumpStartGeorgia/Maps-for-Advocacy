class CreateOrganizationUsers < ActiveRecord::Migration
  def change
    create_table :organization_users do |t|
      t.integer :organization_id
      t.integer :user_id

      t.timestamps
    end
    add_index :organization_users, :organization_id
    add_index :organization_users, :user_id
  end
end
