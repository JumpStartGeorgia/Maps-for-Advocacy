class TrainingVideo < ActiveRecord::Base
  translates :title, :description, :survey_question, :survey_wrong_answer_description, 
      :video_url, :video_embed , :survey_image_description

  has_many :training_video_translations, :dependent => :destroy
  has_many :training_video_results
  accepts_nested_attributes_for :training_video_translations
  attr_accessible :id, :training_video_translations_attributes, :survey_correct_answer, :survey_image
  
  has_attached_file :survey_image, 
    :url => "/system/training_videos/:id/:style/:filename",
    :styles => {
          :thumb => {:geometry => "100x42#"},
          :medium => {:geometry => "400x225#"},
          :survey => {:geometry => "500x500>"},
        }

  validates_attachment :survey_image, :presence => true,
    :content_type => { :content_type => ["image/jpeg", "image/png"] }



  # sort by title
  def self.sorted
    with_translations(I18n.locale).order('training_video_translations.title asc')
  end


  def survey_correct_answer_formatted
    if self.survey_correct_answer == true
      I18n.t('formtastic.yes')
    else
      I18n.t('formtastic.no')
    end
  end
end
