class Question < ActiveRecord::Base
	translates :name

	has_many :question_translations, :dependent => :destroy
  has_many :question_pairings, :dependent => :destroy
  accepts_nested_attributes_for :question_translations
  accepts_nested_attributes_for :question_pairings
  attr_accessible :id, :question_translations_attributes, :question_pairings_attributes

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

end



