class Place < ActiveRecord::Base
	translates :name

  belongs_to :venue
	has_many :place_translations, :dependent => :destroy
	has_many :place_evaluations, :dependent => :destroy
  accepts_nested_attributes_for :place_translations
  accepts_nested_attributes_for :place_evaluations
  attr_accessible :venue_id, :district_id, :lat, :lon, :place_translations_attributes, :place_evaluations_attributes
  
  validates :venue_id, :lat, :lon, :presence => true
  


  def self.places_by_category(venue_category_id=nil)
    sql = "select p.id, pt.name as place, p.lat, p.lon, v.venue_category_id, vt.name as venue "
    sql << "from places as p inner join place_translations as pt on pt.place_id = p.id "
    sql << "inner join venues as v on v.id = p.venue_id "
    sql << "inner join venue_translations as vt on vt.venue_id = v.id "
    sql << "where pt.locale = :locale and vt.locale = :locale "
    if venue_category_id.present?
      sql << "and v.venue_category_id = :venue_category_id "
    end
    sql << "order by pt.name  "
    
    find_by_sql([sql, :locale => I18n.locale, :venue_category_id => venue_category_id])
    
  end
end
