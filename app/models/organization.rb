class Organization < ActiveRecord::Base
	translates :name, :description

	has_many :organization_translations, :dependent => :destroy
  accepts_nested_attributes_for :organization_translations
  attr_accessible :id, :url, :organization_translations_attributes, :avatar

	validates :url, :format => {:with => URI::regexp(['http','https'])}, allow_blank: true

  has_attached_file :avatar, 
    :url => "/system/organizations/:id_:style.:extension",
		:styles => {
			:small => {:geometry => "50x50>"},
			:thumb => {:geometry => "200x200>"}
		}
  

  # sort by name
  def self.sorted
    with_translations(I18n.locale).order('organization_translations.name asc')
  end

end
