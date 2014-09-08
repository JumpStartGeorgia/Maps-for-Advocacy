class Question < ActiveRecord::Base
	translates :name

	has_many :question_translations, :dependent => :destroy
  has_many :question_pairings, :dependent => :destroy
  accepts_nested_attributes_for :question_translations
  accepts_nested_attributes_for :question_pairings
  attr_accessible :id, :question_translations_attributes, :question_pairings_attributes, :unique_id

  def question_category_names
    names = nil
    if self.question_pairings.present?
      cat_ids = self.question_pairings.map{|x| x.question_category_id}
      if cat_ids.present?
        x = QuestionCategoryTranslation.select('name').where(:locale => I18n.locale, :question_category_id => cat_ids)
        if x.present?
          names = x.map{|x| x.name}.join(', ')
        end
      end
    end
    return names
  end
  
  def self.in_category(question_category_id, options={})
    if question_category_id.present?

      sql = "SELECT qp.sort_order as question_sort_order, qp.is_exists, qp.exists_id, qp.exists_parent_id, qp.required_for_accessibility, q.id as question_id, qt.name as question, qp.validation_equation, qp.validation_equation_units, qp.validation_equation_wout_units, qp.is_evidence_angle, qpt.evidence1, qpt.evidence2, qpt.evidence3, qp.id as question_pairing_id, qp.question_category_id "
      if options[:disability_id].present?
        sql << ", dqp.disability_id "
      elsif options[:disability_ids].present?
        sql << ", group_concat(dqp.disability_id) as disability_ids "
      end
      sql << "FROM question_pairings as qp "
      if options[:disability_ids].present?
        sql << "inner JOIN disabilities_question_pairings as dqp ON dqp.question_pairing_id = qp.id and dqp.disability_id in (:disability_ids) "
      elsif options[:disability_id].present?
        sql << "inner JOIN disabilities_question_pairings as dqp ON dqp.question_pairing_id = qp.id and dqp.disability_id = :disability_id "
      end
      sql << "inner JOIN question_pairing_translations as qpt ON qpt.question_pairing_id = qp.id  and qpt.locale = :locale "
      sql << "inner JOIN questions as q ON q.id = qp.question_id " 
      sql << "inner JOIN question_translations as qt ON qt.question_id = q.id and qt.locale = :locale "
      sql << "where qp.question_category_id = :question_category_id "
      if options[:disability_ids].present?
        sql << "group by qp.sort_order, qp.is_exists, qp.exists_id, qp.exists_parent_id, qp.required_for_accessibility, q.id, qt.name, qp.validation_equation, qp.validation_equation_units, qp.validation_equation_wout_units, qp.is_evidence_angle, qpt.evidence1, qpt.evidence2, qpt.evidence3, qp.id, qp.question_category_id "
      end
      sql << "order by qp.sort_order asc, qt.name asc "
      find_by_sql([sql, :locale => I18n.locale, :question_category_id => question_category_id, 
          :disability_id => options[:disability_id], :disability_ids => options[:disability_ids]])

    end
  end
  
  def self.all_questions_not_in_category(question_category_id)
    if question_category_id.present?
      sql = "select q.id, qt.name as question from questions as q "
      sql << "inner join question_translations as qt on qt.question_id = q.id "
      sql << "where qt.locale = :locale and q.id not in (select question_id from question_pairings where question_category_id = :question_category_id) "
      find_by_sql([sql, :locale => I18n.locale, :question_category_id => question_category_id])
    end
  end
  
  def self.add_and_assign_new_question(name_hash, question_category_id, sort_order, evidence_hash)
    Question.transaction do
      q = Question.create

      # get default locale value
      default_locale = I18n.default_locale.to_s
      default = name_hash.has_key?(default_locale) && name_hash[default_locale].present? ? name_hash[default_locale] : nil

      if default.nil?
        # default locale does not have value so get first value and use for default
        I18n.available_locales.map{|x| x.to_s}.each do |locale|
          if name_hash.has_key?(locale) && name_hash[locale].present?
            default = name_hash[locale]
            break
          end
        end            
      end
    
      I18n.available_locales.map{|x| x.to_s}.each do |locale|
        if name_hash.has_key?(locale) && name_hash[locale].present?
          q.question_translations.create(:locale => locale, :name => name_hash[locale])
        else 
          q.question_translations.create(:locale => locale, :name => default)
        end
      end
    
    
      # now create the pairing
      QuestionPairing.add_existing_question(question_category_id, q.id, sort_order, evidence_hash)
      
    end
  end

end



