class CreatePlaceEvaluationImages < ActiveRecord::Migration
  def change
    create_table :place_evaluation_images do |t|
      t.integer :place_evaluation_id
      t.integer :question_pairing_id
      t.integer :place_image_id

      t.timestamps
    end

    add_index :place_evaluation_images, :place_evaluation_id
    add_index :place_evaluation_images, :question_pairing_id
    add_index :place_evaluation_images, :place_image_id
  end

end
