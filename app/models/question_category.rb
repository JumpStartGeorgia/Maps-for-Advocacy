class QuestionCategory < ActiveRecord::Base
	translates :name

  has_one :venue
	has_many :question_category_translations, :dependent => :destroy
	has_many :question_pairings, :dependent => :destroy
	has_many :questions, :through => :question_pairings
  accepts_nested_attributes_for :question_category_translations
  accepts_nested_attributes_for :question_pairings
  attr_accessible :id, :is_common, :question_category_translations_attributes, :question_pairings_attributes, :sort_order


  def self.with_questions(question_category_id=nil)
    sql = "SELECT qc.id, qc.is_common, qc.sort_order, qct.name as question_category, qp.sort_order as question_sort_order, q.id as question_id, qt.name as question, qpt.evidence, qp.id as question_pairing_id "
    sql << "FROM `question_categories` as qc "
    sql << "LEFT OUTER JOIN `question_category_translations` as qct ON qct.`question_category_id` = qc.`id` and qct.`locale` = :locale "
    sql << "LEFT OUTER JOIN `question_pairings` as qp ON qp.`question_category_id` = qc.`id` "
    sql << "LEFT OUTER JOIN `question_pairing_translations` as qpt ON qpt.`question_pairing_id` = qp.`id`  and qpt.`locale` = :locale "
    sql << "LEFT OUTER JOIN `questions` as q ON q.`id` = qp.`question_id` " 
    sql << "LEFT OUTER JOIN `question_translations` as qt ON qt.`question_id` = q.`id` and qt.`locale` = :locale "
    if question_category_id.present?
      sql << "WHERE qc.id = :question_category_id "
    end
    sql << "order by qc.is_common desc, qc.sort_order asc, qct.name asc, qp.sort_order asc, qt.name asc "
    find_by_sql([sql, :locale => I18n.locale, :question_category_id => question_category_id])
  end
end
