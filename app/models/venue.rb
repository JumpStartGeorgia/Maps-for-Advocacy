class Venue < ActiveRecord::Base
	translates :name

	belongs_to :question_category
	belongs_to :venue_category
	has_many :venue_translations, :dependent => :destroy
	has_many :places
  accepts_nested_attributes_for :venue_translations
  attr_accessible :id, :venue_category_id, :question_category_id, :venue_translations_attributes, :sort_order

  validates :venue_category_id, :presence => true


  # take in hash of {id => sort order} for original and new values and
  # if differences are found, update the sort order for that id
  def self.update_sort_order(original_values, new_values)
    if original_values.present? && new_values.present?
      Venue.transaction do
        new_values.keys.each do |key|
          if new_values[key] != original_values[key]
            Venue.where(:id => key).update_all(:sort_order => new_values[key])
          end
        end
      end    
    end
  end

  def self.add_and_assign_new_venue(name_hash, venue_category_id, sort_order)
    Venue.transaction do
      v = Venue.new(:venue_category_id => venue_category_id)
      v.sort_order = sort_order if sort_order.present?
      v.save
      
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
          v.venue_translations.create(:locale => locale, :name => name_hash[locale])
        else 
          v.venue_translations.create(:locale => locale, :name => default)
        end
      end
    
    end
  end


end
