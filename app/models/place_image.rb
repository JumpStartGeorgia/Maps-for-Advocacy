class PlaceImage < ActiveRecord::Base

  include Rails.application.routes.url_helpers
 
  belongs_to :place

  attr_accessible :image, :place_id
  
  has_attached_file :image, 
    :url => "/system/places/:place_id/images/:id_:style.:extension",
		:styles => {
					:thumb => {:geometry => "100x100>"},
					:medium => {:geometry => "450x450>"},
					:large => {:geometry => "900x900>"}
				}
  

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
end
