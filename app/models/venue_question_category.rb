class VenueQuestionCategory < ActiveRecord::Base
  belongs_to :venue
  belongs_to :question_category

  attr_accessible :venue_id, :question_category_id

  validates :venue_id, :question_category_id, :presence => true


  #######################################
  ## load all matches of question categories to venues
  #######################################
  def self.process_complete_csv_upload()
    path = "#{Rails.root}/db/spreadsheets/Accessibility Upload - Venue Question Categories.csv"
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
    idx_venue = 0
    idx_questions_start = 1

		original_locale = I18n.locale
    I18n.locale = :en

    question_categories = QuestionCategory.where(:category_type => QuestionCategory::TYPES['common'])
    venues = Venue.all
    qc_indexes = {}

		VenueQuestionCategory.transaction do
		  if delete_first
        puts "******** deleting all venue question categories on record first"
        # quicker to do delete all instead of destroy        
        VenueQuestionCategory.delete_all
		  end

		
		
		  CSV.parse(infile) do |row|
        startRow = Time.now
		    n += 1
        puts "@@@@@@@@@@@@@@@@@@ processing row #{n}"


        if n == 1
          # get the question categories
          row[idx_questions_start..row.length-1].each_with_index do |qc, col_index|
            index = question_categories.index{|x| x.name.downcase == qc.downcase.strip}
            if index.present?
              qc_indexes[(col_index + idx_questions_start).to_s] = question_categories[index].id
            else
	      		  msg = "Row #{n}: Question Category '#{qc}' could not be found in the database. Please make sure it is spelled correctly."
			        raise ActiveRecord::Rollback
	      		  return msg
            end
          
          end
        
        	puts "******** - qc_indexes = #{qc_indexes}"
        else
          flags_added = 0
          # find the venue
          index = venues.index{|x| x.name.downcase == row[idx_venue].downcase.strip}
          if index.blank?
      		  msg = "Row #{n}: Venue '#{row[idx_name]}' could not be found in the database. Please make sure it is spelled correctly."
		        raise ActiveRecord::Rollback
      		  return msg
          end

          row[idx_questions_start..row.length-1].each_with_index do |flag, col_index|
            if flag.present?
              venues[index].venue_question_categories.create(:question_category_id => qc_indexes[(col_index + idx_questions_start).to_s])
              flags_added += 1
            end
          end          
        	puts "******** - added #{flags_added} question categories for #{row[idx_venue]}"
          
        end
      end
      
    end
  	puts "****************** time to build_from_csv: #{Time.now-start} seconds for #{n} rows"

		# reset the locale
		I18n.locale = original_locale

    return msg
  end

end
