class AddCertificationFlag < ActiveRecord::Migration
  def change
    add_column :place_evaluations, :is_certified, :boolean, :default => false
    add_index :place_evaluations, :is_certified
  end
end
