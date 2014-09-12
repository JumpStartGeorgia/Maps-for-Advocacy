class AddDisabilityOtherField < ActiveRecord::Migration
  def change
  	add_column :place_evaluations, :disability_other_text, :string
  end
end
