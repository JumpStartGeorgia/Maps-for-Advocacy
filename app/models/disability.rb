class Disability < ActiveRecord::Base
	translates :name

	has_many :disability_translations, :dependent => :destroy
	has_many :place_evalations
  has_and_belongs_to_many :question_pairings
  accepts_nested_attributes_for :disability_translations
  attr_accessible :id, :code, :disability_translations_attributes, :active
  
  validates :code, :presence => true

  def self.is_active
    where(:active => true)
  end

  # sort by name
  def self.sorted
    with_translations(I18n.locale).order('disability_translations.name asc')
  end

  # get a disability and include the name
  def self.with_name(id)
    with_translations(I18n.locale).find(id)
  end


  # get number of places with evaluations for each disability
  def self.names_with_count(options={})
    sql = "select d.id, dt.name as disability, count(x.id) as `count`  "
    sql << "from disabilities as d  "
    sql << "inner join disability_translations as dt on dt.disability_id = d.id " 
    sql << "left join (  "
    sql << " select d.id, pe.place_id "
    sql << " from disabilities as d inner join place_evaluations as pe on pe.disability_id = d.id  "
    if options[:venue_category_id].present? || options[:district_id].present?
      sql << " inner join places as p on p.id = pe.place_id "
    end
    if options[:venue_category_id].present?
      sql << " inner join venues as v on v.id = p.venue_id and v.venue_category_id = :venue_category_id "
    end
    if options[:district_id].present?
      # if this is tbilisi, use all districts in tbilisi
      if options[:district_id].to_s == District::TBILISI_ID.to_s
        sql << " inner join districts as ds on ds.id = p.district_id "
        sql << " where ds.in_tbilisi = 1 "
      else
        sql << " where p.district_id = :district_id "
      end
    end
    sql << " group by d.id, pe.place_id  "
    sql << ") as x on x.id = d.id " 
    sql << "where d.active = 1 and dt.locale = :locale "
    sql << "group by d.id, dt.name "
    sql << "order by dt.name "
    find_by_sql([sql, :locale => I18n.locale, :venue_category_id => options[:venue_category_id], :district_id => options[:district_id]])
  end
  

end
