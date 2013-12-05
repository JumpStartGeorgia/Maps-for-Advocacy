class VenueCategory < ActiveRecord::Base
	translates :name

	has_many :venue_category_translations, :dependent => :destroy
  has_many :venues, :dependent => :destroy
  accepts_nested_attributes_for :venue_category_translations
  attr_accessible :id, :venue_category_translations_attributes, :sort_order
  
  def self.with_names
    sql = "select vc.id, vct.name as venue_category "
    sql << "from venue_categories as vc "
    sql << "inner join venue_category_translations as vct on vct.venue_category_id = vc.id "
    sql << "where vct.locale = :locale "
    sql << "order by vc.sort_order, vct.name "
    find_by_sql([sql, :locale => I18n.locale])
  end
  
  
  def self.with_venues(venue_category_id=nil)
    sql = "select vc.id, vct.name as venue_category, vc.sort_order, v.id as venue_id, vt.name as venue, v.sort_order as venue_sort_order, v.question_category_id, qct.name as question_category "
    sql << "from venue_categories as vc "
    sql << "left join venue_category_translations as vct on vct.venue_category_id = vc.id and vct.locale = :locale "
    sql << "left join venues as v on v.venue_category_id = vc.id "
    sql << "left join venue_translations as vt on vt.venue_id = v.id and vt.locale = :locale "
    sql << "left join question_category_translations as qct on qct.question_category_id = v.question_category_id and qct.locale = :locale "
    if venue_category_id.present?
      sql << "where vc.id = :venue_category_id "
    end
    sql << "order by vc.sort_order, vct.name, v.sort_order, vt.name "
    find_by_sql([sql, :locale => I18n.locale, :venue_category_id => venue_category_id])
  end
  
end
