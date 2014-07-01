class Right < ActiveRecord::Base
	translates :name, :convention_article

	has_many :right_translations, :dependent => :destroy
  accepts_nested_attributes_for :right_translations
  attr_accessible :id, :right_translations_attributes
  
  
  # sort by name
  def self.sorted
    with_translations(I18n.locale).order('right_translations.name asc')
  end
end
