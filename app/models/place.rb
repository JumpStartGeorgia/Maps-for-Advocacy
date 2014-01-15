class Place < ActiveRecord::Base
	translates :name, :address

  belongs_to :venue
	has_many :place_translations, :dependent => :destroy
	has_many :place_evaluations, :dependent => :destroy
	has_many :place_images, :dependent => :destroy
  accepts_nested_attributes_for :place_translations
  accepts_nested_attributes_for :place_evaluations
  attr_accessible :venue_id, :district_id, :lat, :lon, :place_translations_attributes, :place_evaluations_attributes
  
  validates :venue_id, :lat, :lon, :presence => true

  include GeoRuby::SimpleFeatures

  after_create :assign_district
  
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
