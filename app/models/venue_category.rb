class VenueCategory < ActiveRecord::Base
	translates :name

	has_many :venue_category_translations, :dependent => :destroy
  has_many :venues, :dependent => :destroy
  accepts_nested_attributes_for :venue_category_translations
  attr_accessible :id, :venue_category_translations_attributes, :sort_order, :unique_id
  
  
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
  ## load all venue categories and venues from the main spreadsheet
  #######################################
  def self.process_complete_csv_upload()
    path = "#{Rails.root}/db/spreadsheets/Accessibility Upload - Venues.csv"
    process_csv_upload(File.open(path, 'r'), true)
  end  
  
  #######################################
  ## update all venue categories and venues from the main spreadsheet
  #######################################
  def self.update_csv_upload()
    path = "#{Rails.root}/db/spreadsheets/Accessibility Upload - Venues.csv"
    process_csv_upload(File.open(path, 'r'), false)
  end  
  
  #######################################
  ## load venue categories and venues
  ## from csv file
  ## - if delete_first is false then will update existing venues
  #######################################
  def self.process_csv_upload(file, delete_first=false)
		start = Time.now
    infile = file.read
    n, msg = 0, ""
    idx_category_id = 0
    idx_category_name = 1
    idx_category_name_ka = 2
    idx_category_sort = 3
    idx_venue_id = 4
    idx_venue_name = 5
    idx_venue_name_ka = 6
    idx_venue_sort = 7
    idx_right = 8
    current_category = nil
    
		original_locale = I18n.locale
    I18n.locale = :en

    accessibility_rights = Right.with_translations(I18n.locale)

		VenueCategory.transaction do
		  if delete_first
        puts "******** deleting all venues on record first"
        # quicker to do delete all instead of destroy        
        VenueCategory.delete_all
        VenueCategoryTranslation.delete_all
        Venue.delete_all
        VenueTranslation.delete_all
        VenueRight.delete_all
        VenueQuestionCategory.delete_all
        Place.delete_all
        PlaceTranslation.delete_all
        PlaceEvaluation.delete_all
        PlaceEvaluationAnswer.delete_all
        PlaceImage.delete_all
        PlaceEvaluationImage.delete_all
        PlaceEvaluationOrganization.delete_all
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
            # need to create new venue category or get it from db if already exists
            current_category = get_category(row[idx_category_id], row[idx_category_name], row[idx_category_name_ka], row[idx_category_sort])
          end

          if current_category.blank? || current_category[:id].blank?
	    		  msg = "Row #{n}: Could not find/create category"
			      raise ActiveRecord::Rollback
	    		  return msg
          end

        	puts "******** - category: #{current_category[:id]}; #{current_category[:name]}"
          
          # create venue
          if row[idx_venue_name].present?
          	v = Venue.includes(:venue_translations).find_by_unique_id(row[idx_venue_id])

            if v.present?
              puts "******** venue exists, updating if needed"
              # record already exists, update it
              v.venue_category_id = current_category[:id] if v.venue_category_id != current_category[:id]
              v.sort_order = row[idx_venue_sort] if v.sort_order != row[idx_venue_sort]
              name = row[idx_venue_name]
              name_ka = row[idx_venue_name_ka]
              v.venue_translations.each do |trans|
                if trans.locale == 'ka' && trans.name != name_ka
                  trans.name = name_ka.present? ? name_ka : name
                elsif trans.locale == 'en' && trans.name != name
                  trans.name = name 
                end
              end

              if !v.save
                msg = "Row #{n}: Could not update venue record due to this error: #{v.errors.full_messages.join(', ')}"
                raise ActiveRecord::Rollback
                return msg
              end
            else
              puts "******** creating venue"
              v = Venue.new(:venue_category_id => current_category[:id], :sort_order => row[idx_venue_sort], :unique_id => row[idx_venue_id])
              I18n.available_locales.each do |locale|
                name = row[idx_venue_name]
                name = row[idx_venue_name_ka] if locale == :ka && row[idx_venue_name_ka].present?
                v.venue_translations.build(:locale => locale, :name => name)
              end

              if !v.save
                msg = "Row #{n}: Could not create venue record due to this error: #{v.errors.full_messages.join(', ')}"
                raise ActiveRecord::Rollback
                return msg
              end
            end

            # add rights
            # there might be multiple rights for a venue
            # - so split by ; and AND
            right = row[idx_right].present? ? row[idx_right].strip : nil
            if right.present?
              rights = []
              right_ids = []
              if right.index('AND').present?
                rights = right.split('AND')
              elsif right.index(';').present?
                rights = right.split(';')
              else
                # no ; or and, so assume just one convention
                rights << right
              end
              rights.map!{|x| x.strip}
              
              # for each right, look for the matching record in db and save id if found
              rights.each do |r|
                if r.present?
                  index = accessibility_rights.index{|x| x.name.downcase == r.downcase.strip}
                  right_id = index.present? ? accessibility_rights[index].id : nil
                  
                  if right_id.present?
                    right_ids << right_id                
                  else
              		  msg = "Row #{n}: Could not match rights '#{r}' with what is in the database. Please make sure it is spelled correctly."
	                  raise ActiveRecord::Rollback
              		  return msg
                  end
                end
              end

              # save the ids
              right_ids.each do |right_id|
                v.venue_rights.create(:right_id => right_id) if v.venue_rights.index{|x| x.right_id == right_id}.nil?
              end
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

		# reset the locale
		I18n.locale = original_locale

    # load the venue question category matrix
    VenueQuestionCategory.process_complete_csv_upload if msg.blank?

  	puts "****************** time to build venue categories csv: #{Time.now-start} seconds for #{n} rows"

    return msg
  end


  ######################################
  ######################################
  ######################################
private
  # get venue category and if not exist, create it
  def self.get_category(unique_id, name, name_ka, sort)
    vc = nil
    unique_id.strip! if unique_id.present?
    name.strip! if name.present?
    name_ka.strip! if name_ka.present?
    sort.strip! if sort.present?
 
    x = includes(:venue_category_translations).find_by_unique_id(unique_id)

    if x.present?
      # update the record if needed
      x.sort_order = sort if x.sort_order != sort

      # update translations if needed
      x.venue_category_translations.each do |trans|
        if trans.locale == 'ka' && trans.name != name_ka
          trans.name = name_ka.present? ? name_ka : name
        elsif trans.locale == 'en' && trans.name != name
          trans.name = name 
        end
      end

      x.save

      # save venue category into variable
      trans = x.venue_category_translations.select{|y| y.locale == I18n.locale.to_s}.first
      vc = {:id => x.id, :name => trans.name}
    end
    
    if vc.nil?
      vc = VenueCategory.create(:sort_order => sort, :unique_id => unique_id)
      I18n.available_locales.each do |locale|
        x = name
        x = name_ka if locale == :ka && name_ka.present?
        vc.venue_category_translations.create(:locale => locale, :name => x)
      end
      vc[:name] = name
    end
    
    return vc
  end
    
end
