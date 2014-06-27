class ConventionCategory < ActiveRecord::Base
	translates :name

	has_many :convention_category_translations, :dependent => :destroy
  accepts_nested_attributes_for :convention_category_translations
  attr_accessible :id, :convention_category_translations_attributes
  
  
  # sort by name
  def self.sorted
    with_translations(I18n.locale).order('convention_category_translations.name asc')
  end
  
end
