class VenueCategory < ActiveRecord::Base
	translates :name

	has_many :venue_category_translations, :dependent => :destroy
  has_many :venues, :dependent => :destroy
  accepts_nested_attributes_for :venue_category_translations
  attr_accessible :id, :venue_category_translations_attributes, :sort_order
  
  
  def self.names_with_count(options={})
    need_and = false
    sql = "select vc.id, vct.name as venue_category, count(x.venue_category_id) as `count` "
    sql << "from venue_categories as vc "
    sql << "inner join venue_category_translations as vct on vct.venue_category_id = vc.id "
    sql << "inner join ( "
    sql << " select v.venue_category_id, p.id as place_id "
    sql << " from venues as v inner join places as p on p.venue_id = v.id "
    if options[:disability_id].present? || options[:places_with_evaluation] == true
      sql << " inner join place_evaluations as pe on pe.place_id = p.id "
      if options[:disability_id].present?
        sql << " and pe.disability_id = :disability_id "
      end
    end
    if options[:place_search].present? || options[:address_search].present?
      sql << " inner join place_translations as pt on pt.place_id = p.id "
    end

    if options[:district_id].present? && options[:district_id].to_s == District::TBILISI_ID.to_s
        sql << " inner join districts as d on d.id = p.district_id "
    end

    if options[:district_id].present? || options[:place_search].present? || options[:address_search].present?
      sql << "where "
      if options[:place_search].present? || options[:address_search].present?
        sql << "pt.locale = :locale "
        need_and = true
      end
    end

    if options[:place_search].present?
      if need_and
        sql << " and "
      end
      sql << " pt.search_name like :place_search "
      need_and = true
    end

    if options[:address_search].present?
      if need_and
        sql << " and "
      end
      sql << " pt.search_address like :address_search "
      need_and = true
    end

    if options[:district_id].present? 
      # if this is tbilisi, use all districts in tbilisi
      if need_and
        sql << "and "
      end
      if options[:district_id].to_s == District::TBILISI_ID.to_s
        sql << " d.in_tbilisi = 1 "
      else
        sql << " p.district_id = :district_id "
      end
    end
    sql << " group by v.venue_category_id, p.id "
    sql << ") as x on x.venue_category_id = vc.id "
    sql << "where vct.locale = :locale "
    sql << "group by vc.id, vct.name "
    sql << "order by vc.sort_order, vct.name "
    find_by_sql([sql, :locale => I18n.locale, :disability_id => options[:disability_id], :district_id => options[:district_id], 
      :place_search => "%#{options[:place_search]}%", :address_search => "%#{options[:address_search]}%"])
  end
  
  # possible options:
  # - venue_category_id: id of venue category to get info for; if not provided then get all venue categories
  # - with_question_category_id: true if want to only get venues that have custom questions
  def self.with_venues(options={})
    with_custom_question_category_id = options[:with_custom_question_category_id] == true ? true : false
    with_custom_public_question_category_id = options[:with_custom_public_question_category_id] == true ? true : false
    
    sql = "select vc.id, vct.name as venue_category, vc.sort_order, v.id as venue_id, vt.name as venue, v.sort_order as venue_sort_order, v.custom_question_category_id, v.custom_public_question_category_id, qct1.name as custom_question_category, qct2.name as custom_public_question_category  "
    sql << "from venue_categories as vc "
    sql << "left join venue_category_translations as vct on vct.venue_category_id = vc.id and vct.locale = :locale "
    sql << "left join venues as v on v.venue_category_id = vc.id "
    sql << "left join venue_translations as vt on vt.venue_id = v.id and vt.locale = :locale "
    sql << "left join question_category_translations as qct1 on qct1.question_category_id = v.custom_question_category_id and qct1.locale = :locale "
    sql << "left join question_category_translations as qct2 on qct2.question_category_id = v.custom_public_question_category_id and qct2.locale = :locale "
    if options[:venue_category_id].present? || with_custom_question_category_id || with_custom_public_question_category_id
      sql << "where "
    end
    if options[:venue_category_id].present?
      sql << "vc.id = :venue_category_id "
    end
    if with_custom_question_category_id
      sql << "v.custom_question_category_id is not null "
    end
    if with_custom_public_question_category_id
      sql << "v.custom_public_question_category_id is not null "
    end
    
    sql << "order by vc.sort_order, vct.name, v.sort_order, vt.name "
    find_by_sql([sql, :locale => I18n.locale, :venue_category_id => options[:venue_category_id]])
  end
  
  
  def self.with_venue_custom_questions(options={})
    venues = []

    ops = {}
    key = :custom_question_category_id
    if options[:is_certified] == true
      ops[:with_custom_question_category_id] = true
    elsif options[:is_certified] == false
      ops[:with_custom_public_question_category_id] = true
      key = :custom_public_question_category_id
    end
    venue_categories = with_venues(ops)
    venue_categories.each do |vc|
      questions = []
      questions = QuestionCategory.custom_questions_for_venue(vc[key], options)      
      venue = {:venue_category => vc[:venue_category], :venue => vc[:venue], :questions => questions}
      venues << venue
    end
        
    return venues
  end
  
  #######################################
  ## load all question categories, quetsions and pairings from the main spreadsheet
  #######################################
  def self.process_complete_csv_upload()
    path = "#{Rails.root}/db/spreadsheets/Accessibility Upload - Venues.csv"
    process_csv_upload(File.open(path, 'r'), true)
  end  
  
  #######################################
  ## load venue categories and venues
  ## from csv file
  #######################################
  def self.process_csv_upload(file, delete_first=false)
		start = Time.now
    infile = file.read
    n, msg = 0, ""
    idx_category_name = 0
    idx_category_name_ka = 1
    idx_category_sort = 2
    idx_venue_name = 3
    idx_venue_name_ka = 4
    idx_venue_sort = 5
    current_category = nil
    
		original_locale = I18n.locale
    I18n.locale = :en

		VenueCategory.transaction do
		  if delete_first
        puts "******** deleting all venues on record first"
        # quicker to do delete all instead of destroy        
        VenueCategory.delete_all
        VenueCategoryTranslation.delete_all
        Venue.delete_all
        VenueTranslation.delete_all
        Place.delete_all
        PlaceTranslation.delete_all
        PlaceEvaluation.delete_all
        PlaceEvaluationAnswer.delete_all
        PlaceSummary.delete_all
		  end
		
		
		  CSV.parse(infile) do |row|
        question = nil
        startRow = Time.now
		    n += 1
        puts "@@@@@@@@@@@@@@@@@@ processing row #{n}"

        if n > 1
          # get venue category
          # if the name does not match the last rows, create it if necessary
          if current_category.nil? || current_category[:name] != row[idx_category_name].strip
            if row[idx_category_name].blank?
	      		  msg = "Row #{n}: Category name is not provided"
			        raise ActiveRecord::Rollback
	      		  return msg
            end

          	puts "******** having to get parent: #{row[idx_category_name]}"
            # need to create new question category or get it from db if already exists
            current_category = get_category(row[idx_category_name], row[idx_category_name_ka], row[idx_category_sort])
          end

          if current_category.blank? || current_category.id.blank?
	    		  msg = "Row #{n}: Could not find/create category"
			      raise ActiveRecord::Rollback
	    		  return msg
          end

        	puts "******** - category: #{current_category.id}; #{current_category[:name]}"
          
          # create venue
          if row[idx_venue_name].present?
          	puts "******** creating venue"
            v = Venue.create(:venue_category_id => current_category.id, :sort_order => row[idx_venue_sort])
            I18n.available_locales.each do |locale|
              name = row[idx_venue_name]
              name = row[idx_venue_name_ka] if locale == :ka
              v.venue_translations.create(:locale => locale, :name => name)
            end
          else
	    		  msg = "Row #{n}: Venue name is not provided"
			      raise ActiveRecord::Rollback
	    		  return msg
          end         
          
        	puts "******** time to process row: #{Time.now-startRow} seconds"
          puts "************************ total time so far : #{Time.now-start} seconds"
        end
      end  
  
		end
  	puts "****************** time to build_from_csv: #{Time.now-start} seconds"

		# reset the locale
		I18n.locale = original_locale

    return msg
  end


  ######################################
  ######################################
  ######################################
private
  # get venue category and if not exist, create it
  def self.get_category(name, name_ka, sort)
    vc = nil
    name.strip! if name.present?
    name_ka.strip! if name_ka.present?
    sort.strip! if sort.present?
    

    x = select('venue_categories.id, venue_category_translations.name').includes(:venue_category_translations)
          .where(:venue_categories => {:sort_order => sort}, :venue_category_translations => {:locale => I18n.locale, :name => name})
          
    vc = x.first if x.present?
    
    if vc.nil?
      vc = VenueCategory.create(:sort_order => sort)
      I18n.available_locales.each do |locale|
        x = name
        x = name_ka if locale == :ka
        vc.venue_category_translations.create(:locale => locale, :name => x)
      end
      vc[:name] = name
    end
    
    return vc
  end
    
end
