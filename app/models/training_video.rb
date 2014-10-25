class TrainingVideo < ActiveRecord::Base
  translates :title, :description, :survey_question, :survey_wrong_answer_description, :video_url, :video_embed 

  has_many :training_video_translations, :dependent => :destroy
  has_many :place_evalations
  has_and_belongs_to_many :question_pairings
  accepts_nested_attributes_for :training_video_translations
  attr_accessible :id, :training_video_translations_attributes, :survey_correct_answer, :survey_image
  
  has_attached_file :survey_image, 
    :url => "/system/training_videos/:id/:style/:filename",
    :styles => {
          :thumb => {:geometry => "50x50#"},
          :medium => {:geometry => "450x450>"},
          :large => {:geometry => "900x900>"}
        }

  validates :survey_correct_answer, :presence => true
  validates_attachment :survey_image, :presence => true,
    :content_type => { :content_type => "image/jpeg" }


  # sort by title
  def self.sorted
    with_translations(I18n.locale).order('training_video_translations.title asc')
  end

end
