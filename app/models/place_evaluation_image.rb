class PlaceEvaluationImage < ActiveRecord::Base
  include Rails.application.routes.url_helpers
 
  belongs_to :place_evaluation
  belongs_to :question_pairing
  belongs_to :user

  attr_accessible :image, :place_evaluation_id, :question_pairing_id, :user_id, :taken_at
  attr_accessor :images
  
  has_attached_file :image, 
    :url => "/system/evaluations/:place_evaluation_id/images/:id_:style.:extension",
		:styles => {
					:thumb => {:geometry => "200x200>"},
					:medium => {:geometry => "450x450>"},
					:large => {:geometry => "900x900>"}
				}
  
  after_post_process :get_meta_data

  # get the meta data from the image
  def get_meta_data
    if self.image.present? && self.image.url.present? && self.image_content_type == "image/jpeg"
      x = EXIFR::JPEG.new(self.image.queued_for_write[:original].path)
      if x.present?
        self.taken_at = x.date_time
      end
    end    
  end


  def self.by_place_evaluation(place_evaluation_id)
    where(:place_evaluation_id => place_evaluation_id)
  end

  def self.with_user
    includes(:user)
  end
  
  def self.sorted
    order('created_at desc')
  end
end
