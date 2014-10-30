class CreateTrainingVideoResults < ActiveRecord::Migration
  def change
    create_table :training_video_results do |t|
      t.integer :training_video_id
      t.integer :user_id
      t.boolean :pre_survey_answer, :default => nil
      t.boolean :post_survey_answer, :default => nil
      t.boolean :watched_video, :default => false

      t.timestamps
    end

    add_index :training_video_results, [:user_id, :watched_video]
  end
end
