class District < ActiveRecord::Base
	translates :name

	has_many :district_translations, :dependent => :destroy
	has_many :places
  accepts_nested_attributes_for :district_translations
  attr_accessible :id, :json, :district_translations_attributes
  validates :json, :presence => true
  
  
  def self.no_json
    select('districts.id, district_translations.name as district_name')
    .joins(:district_translations)
    .where('district_translations.locale = ?', I18n.locale)
    .order('districts.id')
  end
  

  #######################################
  ## load districts from json file
  #######################################
  def self.process_json_upload(file, delete_first=false)
		start = Time.now
    json = file.read
    n, msg = 0, ""
    idx_id = 0
    idx_name = 1
    idx_json = 2

		original_locale = I18n.locale
    I18n.locale = :en

		District.transaction do
		  if delete_first
        puts "******** deleting all districts on record first"
        # quicker to do delete all instead of destroy        
        District.delete_all
        DistrictTranslation.delete_all
		  end
		
      # convert json to hash
      hash = JSON.parse(json)
      
      hash['features'].each_with_index do |feature, index|
        puts "@@@@@@@@@@@@@@@@@@ processing item #{index}"
        id = feature['properties']['District_c']
        name = feature['properties']['District_n']
        geo = feature['geometry']
        if id.present? && name.present? && geo.present?
          # only add if district has id
          if id.to_i > 0
            d = District.create(:id => id.to_i, :json => geo.to_json)
            I18n.available_locales.each do |locale|
              d.district_translations.create(:locale => locale, :name => name.strip)
            end
          end
        else
    		  msg = "Item #{index}: Required data is missing"
	        raise ActiveRecord::Rollback
    		  return msg
        end
      end

    end
  	puts "****************** time to build_from_csv: #{Time.now-start} seconds"

		# reset the locale
		I18n.locale = original_locale

    return msg

  end
  
  #######################################
  ## load districts from csv file
  #######################################
  def self.process_csv_upload(file, delete_first=false)
		start = Time.now
    infile = file.read
    n, msg = 0, ""
    idx_id = 0
    idx_name = 1
    idx_json = 2

		original_locale = I18n.locale
    I18n.locale = :en

		District.transaction do
		  if delete_first
        puts "******** deleting all districts on record first"
        # quicker to do delete all instead of destroy        
        District.delete_all
        DistrictTranslation.delete_all
		  end
		
		
		  CSV.parse(infile, :col_sep => "\t") do |row|
        startRow = Time.now
		    n += 1
        puts "@@@@@@@@@@@@@@@@@@ processing row #{n}"

        # must have all 3 values to save
        if row[idx_id].present? && row[idx_name].present? && row[idx_json].present?
          d = District.create(:id => row[idx_id], :json => row[idx_json].strip)
          I18n.available_locales.each do |locale|
            d.district_translations.create(:locale => locale, :name => row[idx_name].strip)
          end
        else
    		  msg = "Row #{n}: Required data is missing"
	        raise ActiveRecord::Rollback
    		  return msg
        end
      end
    end
  	puts "****************** time to build_from_csv: #{Time.now-start} seconds"

		# reset the locale
		I18n.locale = original_locale

    return msg

  end  
  
  #######################################
  ## load georgian district names from csv file
  #######################################
  def self.process_georgian_name_csv_upload(file)
		start = Time.now
    infile = file.read
    n, msg = 0, ""
    idx_id = 0
    idx_name = 1

		original_locale = I18n.locale
    I18n.locale = :en

		District.transaction do
		  CSV.parse(infile) do |row|
        startRow = Time.now
		    n += 1
        puts "@@@@@@@@@@@@@@@@@@ processing row #{n}"

        # must have all 2 values to save
        if row[idx_id].present? && row[idx_name].present?
          DistrictTranslation.where(:district_id => row[idx_id], :locale => 'ka').update_all(:name => row[idx_name].strip)
        else
    		  msg = "Row #{n}: Required data is missing"
	        raise ActiveRecord::Rollback
    		  return msg
        end
      end
    end
  	puts "****************** time to build_from_csv: #{Time.now-start} seconds"

		# reset the locale
		I18n.locale = original_locale

    return msg

  end    
end
