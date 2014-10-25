class CreateTrainingVideos < ActiveRecord::Migration
  def up
    create_table :training_videos do |t|
      t.string :survey_correct_answer

      t.timestamps
    end

    add_attachment :training_videos, :survey_image

    TrainingVideo.create_translation_table! :title => :string, :description => :text, 
            :survey_question => :string, :survey_wrong_answer_description => :text,
            :video_url => :string, :video_embed => :text

    add_index :training_video_translations, :title

  end

  def down
    drop_table :training_videos
    TrainingVideo.drop_translation_table!
  end
end
