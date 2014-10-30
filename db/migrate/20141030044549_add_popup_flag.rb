class AddPopupFlag < ActiveRecord::Migration
  def change
    add_column :users, :show_popup_training, :boolean, :default => true
  end
end
