class QuestionPairingDisability < ActiveRecord::Base
  translates :content

  belongs_to :question_pairing
  belongs_to :disability

  has_many :question_pairing_disability_translations, :dependent => :destroy

  accepts_nested_attributes_for :question_pairing_disability_translations
  attr_accessible :question_pairing_id, :disability_id, :has_content, :question_pairing_disability_translations_attributes
  
  validates :question_pairing_id, :disability_id, :presence => true


  before_validation :bf
  after_validation :af
  before_save :set_has_content
  after_save :testing
  before_create :bc
  after_create :ac

  def bf
    logger.debug "@@@@@@@@@ before validate qpd"
  end
  def af
    logger.debug "@@@@@@@@@ after validate qpd"
  end
  def bc
    logger.debug "@@@@@@@@@ before create qpd"
  end
  def ac
    logger.debug "@@@@@@@@@ after create qpd"
  end
  def testing
    logger.debug "@@@@@@@@@ after save qpd"
  end

  def save
    logger.debug "@@@@@@@@@ save qpd"

    logger.debug "@@@@@@@@@ - trans records = #{self.question_pairing_disability_translations.map{|x| x.locale}}"

    super

    logger.debug "@@@@@@@@@ - trans records after save = #{self.question_pairing_disability_translations.map{|x| x.locale}}"

  end

  # if the translation object exists and has content, set to true
  def set_has_content
logger.debug "$$$$$$$$$$4444 set has content"
logger.debug "$$$$$$$$$$4444 trans records = #{self.question_pairing_disability_translations.length}"
    
    self.has_content = self.question_pairing_disability_translations.index{|x| x.content.present?}.present?
    
logger.debug "$$$$$$$$$$4444 - has content = #{self.has_content}"

    return true
  end

  # get all records including ties to question category, question and disability tables
  # - if no options are provided, gets all questions pairing disablity records
  # options:
  # - question_pairing_id - gets records that have this id
  # - disability_ids - array of disability_ids to get records for
  # - search - phrase to search for
  # - sort_col - col to sort by
  # - sort_dir - direction to sort by
  # - limit - number of records to get
  # - offset - offset for pagination
  # - is_certified - boolean flag indicating to show public or certified records
  # - type - what disability type
  # - category - what category records have to belong to
  def self.with_names(options={})
    question_pairing_id = options[:question_pairing_id].present? ? options[:question_pairing_id] : nil
    disability_ids = options[:disability_ids].present? ? options[:disability_ids] : nil
    search = options[:search].present? ? options[:search] : nil
    sort_col = options[:sort_col].present? ? options[:sort_col] : nil
    sort_dir = options[:sort_dir].present? ? options[:sort_dir] : nil
    limit = options[:limit].present? ? options[:limit] : nil
    offset = options[:offset].present? ? options[:offset] : nil
    is_certified = options[:is_certified].present? ? options[:is_certified].to_s.to_bool : nil
    type = options[:type].present? ? options[:type] : nil
    category = options[:category].present? ? options[:category] : nil

    sql = "SELECT qpd.id, qpd.question_pairing_id, qpd.disability_id, qpd.has_content, "
    sql << "if (qc_child.category_type = :common or qc_child.category_type = :custom, 1, 0) as is_certified,"
    sql << "if (qc_child.ancestry is null, qct_child.name, qct_parent.name) as question_category_parent, "
    sql << "if (qc_child.ancestry is null, null, qct_child.name) as question_category_child, "
    sql << "qt.name as question, dt.name as disability_name "
    sql << "from question_pairing_disabilities as qpd "
    sql << "left join question_pairing_disability_translations as qpdt ON qpdt.question_pairing_disability_id = qpd.id and qpdt.locale = :locale "
    sql << "inner join disabilities as d ON d.id = qpd.disability_id "
    sql << "inner join disability_translations as dt ON dt.disability_id = d.id and dt.locale = :locale "
    sql << "inner join question_pairings as qp ON qp.id = qpd.question_pairing_id "
    sql << "inner join questions as q ON q.id = qp.question_id "
    sql << "inner join question_translations as qt ON qt.question_id = q.id  and qt.locale = :locale "
    sql << "inner join question_categories as qc_child ON qc_child.id = qp.question_category_id "
    sql << "inner join question_category_translations as qct_child ON qct_child.question_category_id = qc_child.id  and qct_child.locale = :locale "
    sql << "left join question_categories as qc_parent ON qc_parent.id = qc_child.ancestry "
    sql << "left join question_category_translations as qct_parent ON qct_parent.question_category_id = qc_parent.id and qct_parent.locale = :locale "
    if question_pairing_id.present?
      sql << "where qpd.question_pairing_id = :question_pairing_id "
      if disability_ids.present?
        sql << "and qpd.disability_id in (:disability_ids) "
      end
    elsif search.present? || is_certified.to_s.present? || type.present? || category.present?
      sql << "where "
      has_content = false

      if search.present?
        sql << "(qct_child.name like :search or qct_parent.name like :search || qt.name like :search || dt.name like :search ) "
        has_content = true
      end
      
      if is_certified.to_s.present?
        if has_content
          sql << "and "
        end
        if !is_certified
          sql << "!"
        end
        sql << "(qc_child.category_type = :common or qc_child.category_type = :custom) "
        has_content = true
      end

      if type.present? && type != "0"
        if has_content
          sql << "and "
        end
        sql << "qpd.disability_id = :type "
        has_content = true
      end

      if category.present? && category != '0'
        if has_content
          sql << "and "
        end
        sql << "(qc_child.id = :category || qc_parent.id = :category) "
      end
    end
    if question_pairing_id.blank?
      if sort_col.present?
        # have to add the sort cols/dirn here instead of in the list of args below 
        # so that the '' are not included around the text items and so the order by works
        sql << "order by #{sort_col} #{sort_dir} "
      else
        sql << "order by qc_parent.sort_order, qc_child.sort_order, qp.sort_order "
      end
=begin      
      if limit.present?
        sql << "limit :limit "
      end
      if offset.present?
        sql << "offset :offset "
      end      
=end      
    end

    paginate_by_sql([sql, :common => QuestionCategory::TYPES['common'], 
                :custom => QuestionCategory::TYPES['custom'],
                :locale => I18n.locale, :question_pairing_id => question_pairing_id,
                :disability_ids => disability_ids, :search => "%#{search}%",
                :sort_col => sort_col, :sort_dir => sort_dir,
                :type => type, :category => category],
                :page => offset, :per_page => limit)

    # find_by_sql([sql, :common => QuestionCategory::TYPES['common'], 
    #             :custom => QuestionCategory::TYPES['custom'],
    #             :locale => I18n.locale, :question_pairing_id => question_pairing_id,
    #             :disability_ids => disability_ids, :search => search,
    #             :sort_col => sort_col, :sort_dir => sort_dir,
    #             :limit => limit, :offset => offset])

  end

  # get count of all records including ties to question category, question and disability tables
  # - if no options are provided, gets all questions pairing disablity records
  # options:
  # - question_pairing_id - gets records that have this id
  # - disability_ids - array of disability_ids to get records for
  def self.with_names_count(options={})
    question_pairing_id = options[:question_pairing_id].present? ? options[:question_pairing_id] : nil
    disability_ids = options[:disability_ids].present? ? options[:disability_ids] : nil
    sql = "SELECT count(*) as count "
    sql << "from question_pairing_disabilities as qpd "
    sql << "left join question_pairing_disability_translations as qpdt ON qpdt.question_pairing_disability_id = qpd.id and qpdt.locale = :locale "
    sql << "inner join disabilities as d ON d.id = qpd.disability_id "
    sql << "inner join disability_translations as dt ON dt.disability_id = d.id and dt.locale = :locale "
    sql << "inner join question_pairings as qp ON qp.id = qpd.question_pairing_id "
    sql << "inner join questions as q ON q.id = qp.question_id "
    sql << "inner join question_translations as qt ON qt.question_id = q.id  and qt.locale = :locale "
    sql << "inner join question_categories as qc_child ON qc_child.id = qp.question_category_id "
    sql << "inner join question_category_translations as qct_child ON qct_child.question_category_id = qc_child.id  and qct_child.locale = :locale "
    sql << "left join question_categories as qc_parent ON qc_parent.id = qc_child.ancestry "
    sql << "left join question_category_translations as qct_parent ON qct_parent.question_category_id = qc_parent.id and qct_parent.locale = :locale "
    if question_pairing_id.present?
      sql << "where qpd.question_pairing_id = :question_pairing_id "
      if disability_ids.present?
        sql << "and qpd.disability_id in (:disability_ids) "
      end
    end

    x = find_by_sql([sql, :common => QuestionCategory::TYPES['common'], 
                :custom => QuestionCategory::TYPES['custom'],
                :locale => I18n.locale, :question_pairing_id => question_pairing_id,
                :disability_ids => disability_ids])

    return x.first['count']
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
