class QuestionPairingDisability < ActiveRecord::Base
  translates :content

  belongs_to :question_pairing
  belongs_to :disability

  has_many :question_pairing_disability_translations, :dependent => :destroy

  accepts_nested_attributes_for :question_pairing_disability_translations
  attr_accessible :question_pairing_id, :disability_id, :has_content, :question_pairing_disability_translations_attributes
  
  validates :question_pairing_id, :disability_id, :presence => true


  before_save :set_has_content

  # if the translation object exists and has content, set to true
  def set_has_content
    has = false
    
    self.question_pairing_disability_translations.each do |trans|
      if trans.content.present?
        has = true
      end
    end

    self.has_content = has

    return true
  end

  # get all records including ties to question category, question and disability tables
  def self.sorted_with_names(limit=nil)
    sql = "SELECT qpd.id, qpd.question_pairing_id, qpd.disability_id, qpd.has_content, "
    sql << "if (qc_child.category_type = :common or qc_child.category_type = :custom, 1, 0) as is_certified,"
    sql << "if (qc_child.ancestry is null, qct_child.name, qct_parent.name) as question_category_parent, "
    sql << "if (qc_child.ancestry is null, null, qct_child.name) as question_category_child, "
    sql << "qt.name as question,"
    sql << "dt.name as disability_name "
    sql << "from question_pairing_disabilities as qpd "
    sql << "left join question_pairing_disability_translations as qpdt ON qpdt.question_pairing_disability_id = qpd.id "
    sql << "inner join disabilities as d ON d.id = qpd.disability_id "
    sql << "inner join disability_translations as dt ON dt.disability_id = d.id and dt.locale = :locale "
    sql << "inner join question_pairings as qp ON qp.id = qpd.question_pairing_id "
    sql << "inner join questions as q ON q.id = qp.question_id "
    sql << "inner join question_translations as qt ON qt.question_id = q.id  and qt.locale = :locale "
    sql << "inner join question_categories as qc_child ON qc_child.id = qp.question_category_id "
    sql << "inner join question_category_translations as qct_child ON qct_child.question_category_id = qc_child.id  and qct_child.locale = :locale "
    sql << "left join question_categories as qc_parent ON qc_parent.id = qc_child.ancestry "
    sql << "left join question_category_translations as qct_parent ON qct_parent.question_category_id = qc_parent.id and qct_parent.locale = :locale "
    sql << "order by qc_parent.sort_order, qc_child.sort_order, qp.sort_order "
    if limit.present? && limit > 0
      sql << "limit :limit "
    end

    find_by_sql([sql, :common => QuestionCategory::TYPES['common'], 
                :custom => QuestionCategory::TYPES['custom'],
                :locale => I18n.locale, :limit => limit])
  end

  # if quesiton category type - 1/2 -> certified
  # else public
  def is_certified?
    self[:is_certified].to_s.to_bool
  end

  def certified_text
    if self.is_certified?
      I18n.t('app.common.certified')
    else
      I18n.t('app.common.public')
    end
  end

  def question_category
    self[:question_category_parent]
  end

  def question_subcategory
    self[:question_category_child]
  end

  def question
    self[:question]
  end

  def disability_name
    self[:disability_name]
  end
end
