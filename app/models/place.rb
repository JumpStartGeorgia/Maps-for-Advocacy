class Place < ActiveRecord::Base
	translates :name, :address

  belongs_to :venue
	has_many :place_translations, :dependent => :destroy
	has_many :place_evaluations, :dependent => :destroy
	has_many :place_images, :dependent => :destroy
	has_many :place_summaries, :dependent => :destroy
  accepts_nested_attributes_for :place_translations
  accepts_nested_attributes_for :place_evaluations
  attr_accessible :venue_id, :district_id, :lat, :lon, :place_translations_attributes, :place_evaluations_attributes
  
  validates :venue_id, :lat, :lon, :presence => true

  include GeoRuby::SimpleFeatures

  after_create :assign_district

  # get the count of places that belong to any of the passed in venue ids
  # - venue_ids: array of venue ids
  def self.count_with_venues(venue_ids)
    count = 0
    if venue_ids.present?
      count = where(venue_id: venue_ids).count
    end
    return count  
  end
  
  # get all place ids that are assigned to the passed in venue ids
  # - venue_ids: array of venue ids
  def self.ids_in_venues(venue_ids)
    if venue_ids.present?
      select('id')
      .where(venue_id: venue_ids)
      .map{|x| x.id}.uniq
    end
  end



  # get the venue and venue category id for a place
  # - place_id: id of place
  # return: {:venue_id, :venue_category_id}
  def self.place_venue_ids(place_id)
    ids = nil
    sql = "select v.venue_category_id, p.venue_id from places as p inner join venues as v on v.id = p.venue_id "
    sql << "where p.id = "
    sql << place_id.to_s
    venue = find_by_sql(sql)
    
    if venue.present?
      ids = Hash.new
      ids[:venue_id] = venue[0][:venue_id]
      ids[:venue_category_id] = venue[0][:venue_category_id]
    end
    
    return ids
  end


  
  def self.with_translation(id=nil)
    sql = "select p.id, p.district_id, dt.name as district, p.venue_id, vt.name as venue, v.question_category_id, v.venue_category_id, p.lat, p.lon, pt.name as place, pt.address "
    sql << "from places as p "
    sql << "inner join place_translations as pt on pt.place_id = p.id and pt.locale = :locale "
    sql << "left join venues as v on v.id = p.venue_id "
    sql << "left join venue_translations as vt on vt.venue_id = v.id and vt.locale = :locale "
    sql << "left join district_translations as dt on dt.district_id = p.district_id and dt.locale = :locale "
    if id.present?
      sql << "where p.id = :place_id "
    end
    find_by_sql([sql, :locale => I18n.locale, :place_id => id])
  end
  

  def self.filtered(options={})
    sql = "select distinct p.id, pt.name as place, pt.address, p.lat, p.lon, v.venue_category_id, vt.name as venue "
    sql << "from places as p inner join place_translations as pt on pt.place_id = p.id "
    sql << "inner join venues as v on v.id = p.venue_id "
    sql << "inner join venue_translations as vt on vt.venue_id = v.id "
    if options[:disability_id].present?
      sql << "inner join place_evaluations as pe on pe.place_id = p.id and pe.disability_id = :disability_id "
    end
    # if this is tbilisi, use all districts in tbilisi
    if options[:district_id].present? && options[:district_id].to_s == District::TBILISI_ID.to_s
      sql << " inner join districts as d on d.id = p.district_id "
    end
    sql << "where pt.locale = :locale and vt.locale = :locale "
    if options[:venue_category_id].present?
      sql << "and v.venue_category_id = :venue_category_id "
    end
    if options[:district_id].present?
      # if this is tbilisi, use all districts in tbilisi
      if options[:district_id].to_s == District::TBILISI_ID.to_s
        sql << " and d.in_tbilisi = 1 "
      else
        sql << " and p.district_id = :district_id "
      end
    end
    sql << "order by pt.name  "
    
    find_by_sql([sql, :locale => I18n.locale, :venue_category_id => options[:venue_category_id], 
      :disability_id => options[:disability_id], :district_id => options[:district_id]])
    
  end


  def assign_district
    require 'geo_ruby/geojson'
    
    point = Point.from_lon_lat(self.lon, self.lat)
    
    districts = District.order('id')
    districts.each do |district|
      geo = Geometry.from_geojson(district.json)
      if geo.contains_point?(point)
        self.district_id = district.id
        self.save
        break
      end
    end
    return nil
  end
end
