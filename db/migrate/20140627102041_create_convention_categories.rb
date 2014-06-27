class CreateConventionCategories < ActiveRecord::Migration
  def up
    create_table :convention_categories do |t|
      t.timestamps
    end

    ConventionCategory.create_translation_table! :name => :string
    add_index :convention_category_translations, :name
  end
  
  def down
    drop_table :convention_categories
    ConventionCategory.drop_translation_table!
  end
end
