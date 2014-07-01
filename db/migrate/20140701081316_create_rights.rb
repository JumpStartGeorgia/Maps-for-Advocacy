class CreateRights < ActiveRecord::Migration
  def up
    create_table :rights do |t|
      t.timestamps
    end

    Right.create_translation_table! :name => :string, :convention_article => :string
    add_index :right_translations, :name
  end
  
  def down
    drop_table :rights
    Right.drop_translation_table!
  end
end
