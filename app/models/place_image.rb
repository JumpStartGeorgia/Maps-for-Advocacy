class PlaceImage < ActiveRecord::Base

  include Rails.application.routes.url_helpers
 
  belongs_to :place
  belongs_to :user

  attr_accessible :image, :place_id, :user_id, :taken_at
  
  has_attached_file :image, 
    :url => "/system/places/:place_id/images/:id_:style.:extension",
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


  # hash required for jquery upload script
  def to_jq_upload
    {
      "name" => read_attribute(:image_file_name),
      "size" => read_attribute(:image_file_size),
      "url" => image.url(:large),
      "thumbnail_url" => image.url(:thumb),
      "delete_url" => place_destroy_photo_path(:id => self.id, :place_id => self.place_id, :locale => I18n.locale),
      "delete_type" => "DELETE" 
    }
  end
  
  def self.by_place(place_id)
    where(:place_id => place_id)
  end

  def self.with_user
    includes(:user)
  end
  
  def self.sorted
    order('created_at desc')
  end
end
