class UpdatePageSize < ActiveRecord::Migration
  def up
    change_column :page_translations, :content, :text, :limit => 16777215
  end

  def down
    change_column :page_translations, :content, :text, :limit => 65535
  end
end
