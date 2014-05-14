class AddVenueQcField < ActiveRecord::Migration
  def change
    remove_index :venues, :question_category_id
    rename_column :venues, :question_category_id, :custom_question_category_id
    add_column :venues, :custom_public_question_category_id, :integer
    add_index :venues, :custom_question_category_id
    add_index :venues, :custom_public_question_category_id
  end
end
