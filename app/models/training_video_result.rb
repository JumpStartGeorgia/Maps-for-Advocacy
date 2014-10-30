class TrainingVideoResult < ActiveRecord::Base
  belongs_to :user
  belongs_to :training_video

  attr_accessible :training_video_id, :user_id, :pre_survey_answer, :post_survey_answer, :watched_video

     
  # return flag indicating if user has watched any videos 
  def self.watched_videos?(user_id)
    where(:user_id => user_id).count > 0 ? true : false
  end

  # get list of all videos user has watched
  def self.watched_videos(user_id)
    where(:user_id => user_id)
  end
end
