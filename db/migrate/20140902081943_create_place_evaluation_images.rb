class CreatePlaceEvaluationImages < ActiveRecord::Migration
  def up
    create_table :place_evaluation_images do |t|
      t.integer :place_evaluation_id
      t.integer :question_pairing_id
      t.integer :user_id
      t.datetime :taken_at

      t.timestamps
    end

    add_index :place_evaluation_images, :place_evaluation_id
    add_index :place_evaluation_images, :question_pairing_id
    add_index :place_evaluation_images, :user_id  
    add_index :place_evaluation_images, :taken_at
    
    add_attachment :place_evaluation_images, :image
  end

  def down
    remove_index :place_evaluation_images, :place_evaluation_id
    remove_index :place_evaluation_images, :question_pairing_id
    remove_index :place_evaluation_images, :user_id  
    remove_index :place_evaluation_images, :taken_at

    drop_table :place_evaluation_images
  end
end
