class QuestionPairing < ActiveRecord::Base
	translates :evidence

	belongs_to :question_category
	belongs_to :question
	has_many :question_pairing_translations, :dependent => :destroy
	has_many :place_evaluation_answers, :dependent => :destroy
  has_and_belongs_to_many :disabilities
  accepts_nested_attributes_for :question_pairing_translations
  attr_accessible :id, :question_category_id, :question_id, :question_pairing_translations_attributes, :sort_order, :is_exists, :required_for_accessibility


  # take in hash of {id => sort order} for original and new values and
  # if differences are found, update the sort order for that id
  def self.update_sort_order(original_values, new_values)
    if original_values.present? && new_values.present?
      QuestionPairing.transaction do
        new_values.keys.each do |key|
          if new_values[key] != original_values[key]
            QuestionPairing.where(:id => key).update_all(:sort_order => new_values[key])
          end
        end
      end    
    end
  end


  # add an existing question to a question category
  def self.add_existing_question(question_category_id, question_id, sort_order, evidence_hash)
    if question_category_id.present? && question_id.present?
      QuestionPairing.transaction do
        qp = QuestionPairing.create(:question_category_id => question_category_id, :question_id => question_id)
        
        if evidence_hash.present? && !(evidence_hash.values.uniq.length == 1 && evidence_hash.values.uniq.first.blank?)
          # get default locale value
          default_locale = I18n.default_locale.to_s
          default = evidence_hash.has_key?(default_locale) && evidence_hash[default_locale].present? ? evidence_hash[default_locale] : nil

          if default.nil?
            # default locale does not have value so get first value and use for default
            I18n.available_locales.map{|x| x.to_s}.each do |locale|
              if evidence_hash.has_key?(locale) && evidence_hash[locale].present?
                default = evidence_hash[locale]
                break
              end
            end            
          end

          I18n.available_locales.map{|x| x.to_s}.each do |locale|
            if evidence_hash.has_key?(locale) && evidence_hash[locale].present?
              qp.question_pairing_translations.create(:locale => locale, :evidence => evidence_hash[locale])
            else 
              qp.question_pairing_translations.create(:locale => locale, :evidence => default)
            end
          end
        end

        if sort_order.present?
          qp.sort_order = sort_order
          qp.save
        end

      end  
    end
  end

end
