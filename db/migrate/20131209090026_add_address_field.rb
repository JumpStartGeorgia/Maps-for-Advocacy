class AddAddressField < ActiveRecord::Migration
  def change
    add_column :place_translations, :address, :string
  end
end
