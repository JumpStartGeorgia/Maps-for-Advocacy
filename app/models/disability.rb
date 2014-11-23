class Disability < ActiveRecord::Base
	translates :name

	has_many :disability_translations, :dependent => :destroy
	has_many :place_evalations
  has_many :question_pairing_disabilities
#  has_and_belongs_to_many :question_pairings
  accepts_nested_attributes_for :disability_translations
  attr_accessible :id, :code, :disability_translations_attributes, :active_public, :active_certified, :sort_order
  
  validates :code, :presence => true

  OTHER_ID = 9

  def self.is_active
    where('active_public = 1 or active_certified = 1')
  end

  def self.is_active_public
    where(:active_public => true)
  end

  def self.is_active_certified
    where(:active_certified => true)
  end

  # sort by name
  def self.sorted
    with_translations(I18n.locale).order('disabilities.sort_order asc, disability_translations.name asc')
  end

  # get a disability and include the name
  def self.with_name(id)
    with_translations(I18n.locale).find(id)
  end


  # get number of places with evaluations for each disability
  def self.names_with_count(options={})
    need_and = false
    sql = "select d.id, dt.name as disability, count(x.id) as `count`  "
    sql << "from disabilities as d  "
    sql << "inner join disability_translations as dt on dt.disability_id = d.id " 
    sql << "inner join ( "
    sql << " select d.id, pe.place_id "
    sql << " from disabilities as d inner join place_evaluations as pe on pe.disability_id = d.id  "
    if options[:venue_category_id].present? || options[:district_id].present? || 
        options[:place_search].present?  || options[:address_search].present?
      sql << " inner join places as p on p.id = pe.place_id "
    end
    if options[:venue_category_id].present?
      sql << " inner join venues as v on v.id = p.venue_id and v.venue_category_id = :venue_category_id "
    end
    if options[:place_search].present? || options[:address_search].present?
      sql << " inner join place_translations as pt on pt.place_id = p.id "
    end

    if options[:district_id].present? && options[:district_id].to_s == District::TBILISI_ID.to_s
        sql << " inner join districts as d on d.id = p.district_id "
    end
    
    if options[:district_id].present? || options[:place_search].present? || options[:address_search].present?
      sql << "where "
      if options[:place_search].present? || options[:address_search].present?
        sql << "pt.locale = :locale "
        need_and = true
      end
    end

    if options[:place_search].present?
      if need_and
        sql << " and "
      end
      sql << " pt.search_name like :place_search "
      need_and = true
    end

    if options[:address_search].present?
      if need_and
        sql << " and "
      end
      sql << " pt.search_address like :address_search "
      need_and = true
    end

    if options[:district_id].present? 
      # if this is tbilisi, use all districts in tbilisi
      if need_and
        sql << "and "
      end
      if options[:district_id].to_s == District::TBILISI_ID.to_s
        sql << " d.in_tbilisi = 1 "
      else
        sql << " p.district_id = :district_id "
      end
    end

    sql << " group by d.id, pe.place_id  "
    sql << ") as x on x.id = d.id " 
    sql << "where (d.active_public = 1 or d.active_certified = 1) and dt.locale = :locale "
    sql << "group by d.id, dt.name "
    sql << "order by dt.name "
    find_by_sql([sql, :locale => I18n.locale, :venue_category_id => options[:venue_category_id], :district_id => options[:district_id], 
      :place_search => "%#{options[:place_search]}%", :address_search => "%#{options[:address_search]}%"])
  end
  

end
