class CreatePlaceEvaluations < ActiveRecord::Migration
  def change
    create_table :place_evaluations do |t|
      t.integer :place_id
      t.integer :user_id
      t.integer :question_pairing_id
      t.integer :answer
      t.string :evidence

      t.timestamps
    end
    
    add_index :place_evaluations, :user_id
    add_index :place_evaluations, :place_id
    add_index :place_evaluations, :question_pairing_id
    
  end
end
