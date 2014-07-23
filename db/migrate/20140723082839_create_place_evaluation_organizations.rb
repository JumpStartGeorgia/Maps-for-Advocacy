class CreatePlaceEvaluationOrganizations < ActiveRecord::Migration
  def change
    create_table :place_evaluation_organizations do |t|
      t.integer :place_evaluation_id
      t.integer :organization_id

      t.timestamps
    end
    add_index :place_evaluation_organizations, :organization_id
    add_index :place_evaluation_organizations, :place_evaluation_id
  end
end
