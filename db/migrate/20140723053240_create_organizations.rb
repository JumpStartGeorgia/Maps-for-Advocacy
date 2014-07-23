class CreateOrganizations < ActiveRecord::Migration
  def up
    create_table :organizations do |t|
      t.string :url

      t.timestamps
    end

    add_attachment :organizations, :avatar

    Organization.create_translation_table! :name => :string, :description => :text
    add_index :organization_translations, :name
    
  end
  
  def down
    drop_table :organizations
    Organization.drop_translation_table!
  end
end
