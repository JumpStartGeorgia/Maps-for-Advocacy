class TrainingVideoTranslation < ActiveRecord::Base
  belongs_to :training_video

  attr_accessible :training_video_id, :locale, :title, :description, 
      :survey_question, :survey_wrong_answer_description, :video_url, :video_embed, :survey_image_description

  validates :title, :survey_question, :video_url, :presence => true
  validates :video_url, :format => {:with => URI::regexp(['http','https'])}

  def required_data_provided?
    provided = false
    
    provided = self.title.present? && #self.description.present? && 
              self.survey_question.present? && #self.survey_wrong_answer_description.present? &&
              self.video_url.present? && self.video_embed.present?

    return provided
  end
  
  def add_required_data(obj)
    self.title = obj.title if self.title.blank?
    self.description = obj.description if self.description.blank?
    self.survey_question = obj.survey_question if self.survey_question.blank?
    self.survey_wrong_answer_description = obj.survey_wrong_answer_description if self.survey_wrong_answer_description.blank?
    self.video_url = obj.video_url if self.video_url.blank?
    self.video_embed = obj.video_embed if self.video_embed.blank?
    self.survey_image_description = obj.survey_image_description if self.survey_image_description.blank?
  end

end
