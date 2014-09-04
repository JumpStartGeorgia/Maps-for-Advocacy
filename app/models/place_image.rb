class PlaceImage < ActiveRecord::Base

  include Rails.application.routes.url_helpers
 
  belongs_to :place
  belongs_to :user
  has_many :place_evaulation_images, :dependent => :destroy
  
  attr_accessible :image, :place_id, :user_id, :taken_at
  attr_accessor :nickname, :is_certified, :disability, :question, :answer
  
  has_attached_file :image, 
    :url => "/system/places/:place_id/images/:id_:style.:extension",
		:styles => {
					:thumb => {:geometry => "50x50#"},
					:medium => {:geometry => "450x450>"},
					:large => {:geometry => "900x900>"}
				}
  

  validates_attachment_content_type :image, :content_type => "image/jpeg"

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

=begin
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
=end

  # get all images in a place
  # - inlcude user nickname, evaluation type, disability type, question and answer
  def self.by_place(place_id)
    sql = "select pi.id, pi.image_file_name, pi.place_id, pi.taken_at, pi.created_at, u.nickname, pe.is_certified, dt.name as disability, qt.name as question, pea.answer "
    sql << "from place_evaluation_images as pei "
    sql << "inner join place_images as pi on pi.id = pei.place_image_id "
    sql << "inner join users as u on u.id = pi.user_id "
    sql << "inner join place_evaluations as pe on pei.place_evaluation_id = pe.id "
    sql << "inner join disability_translations as dt on dt.disability_id = pe.disability_id "
    sql << "inner join place_evaluation_answers as pea on pea.question_pairing_id = pei.question_pairing_id and pea.place_evaluation_id = pei.place_evaluation_id "
    sql << "inner join question_pairings as qp on qp.id = pei.question_pairing_id "
    sql << "inner join question_translations as qt on qt.question_id = qp.question_id "
    sql << "where pi.place_id = :place_id and qt.locale = :locale and dt.locale = :locale "
    sql << "order by pe.is_certified desc, disability "
    
    find_by_sql([sql, place_id: place_id, locale: I18n.locale])
  end




end
