class QuestionCategory < ActiveRecord::Base
	translates :name
  has_ancestry

  has_one :venue
	has_many :question_category_translations, :dependent => :destroy
	has_many :question_pairings, :dependent => :destroy
	has_many :questions, :through => :question_pairings
  accepts_nested_attributes_for :question_category_translations
  accepts_nested_attributes_for :question_pairings
  attr_accessible :id, :is_common, :question_category_translations_attributes, :question_pairings_attributes, :sort_order

  before_save :set_sort_order
  DEFAULT_SORT_ORDER = 99
  
  def set_sort_order
    self.sort_order = DEFAULT_SORT_ORDER if read_attribute(:sort_order).blank?
  end


  # possible options: common_only, child_of, question_category_id, disability_id
  def self.with_questions(options = {})
    categories = nil
    options[:common_only] = false if options[:common_only].nil?

    categories = with_translations(I18n.locale).order('question_categories.sort_order asc')
    if options[:child_of].present?
      categories = categories.where('question_categories.ancestry = ?', options[:child_of]) 
    else
      categories = categories.where('question_categories.ancestry is null') 
    end
    categories = categories.where('question_categories.is_common = 1') if options[:common_only].present?
    categories = categories.where('question_categories.id = ?', options[:question_category_id]) if options[:question_category_id].present?
    
    if categories.present?
    
      categories.each do |cat|
        # get the questions for this category
        cat[:questions] = Question.in_category(cat.id, options[:disability_id])

        # if this category has sub_categories, get them too
        if cat.has_children?
          new_options = {:child_of => cat.path_ids.join('/'), :common_only => options[:common_only], :disability_id => options[:disability_id]}

          cat[:sub_categories] = with_questions(new_options)
        end
      
      end
    
    end
  
    return categories
  end

  def self.with_questions_old(options = {})
    options[:common_only] = false if options[:common_only].nil?
    
    sql = "SELECT qc.id, qc.is_common, qc.sort_order, qct.name as question_category, qp.sort_order as question_sort_order, q.id as question_id, qt.name as question, qpt.evidence, qp.id as question_pairing_id "
    sql << "FROM question_categories as qc "
    sql << "LEFT OUTER JOIN question_category_translations as qct ON qct.question_category_id = qc.id and qct.locale = :locale "
    sql << "LEFT OUTER JOIN question_pairings as qp ON qp.question_category_id = qc.id "
    sql << "LEFT OUTER JOIN question_pairing_translations as qpt ON qpt.question_pairing_id = qp.id  and qpt.locale = :locale "
    sql << "LEFT OUTER JOIN questions as q ON q.id = qp.question_id " 
    sql << "LEFT OUTER JOIN question_translations as qt ON qt.question_id = q.id and qt.locale = :locale "
    sql << "where qc.ancestry is null "
    if options[:question_category_id].present? || options[:common_only]
      and_required = options[:question_category_id].present? && options[:common_only]
      if options[:question_category_id].present?
        sql << "and qc.id = :question_category_id "
      end
      if and_required
#        sql << "and "
      end
      if options[:common_only]
        sql << "and qc.is_common = 1 "
      end
    end
#    sql << "order by qc.is_common desc, qc.sort_order asc, qct.name asc, qp.sort_order asc, qt.name asc "
    find_by_sql([sql, :locale => I18n.locale, :question_category_id => options[:question_category_id]])
  end
  

  # get all common questions and any special questions if a question category id is provided  
  # possible options: question_category_id, disability_id
  def self.questions_for_venue(options = {})
    questions = []

    # get custom questions
    if options[:question_category_id].present?
      questions << with_questions(options)      
    end
    
    # get common questions
    ops = {:common_only => true}
    ops[:disability_id] = options[:disability_id] if options[:disability_id].present?
    questions << with_questions(ops)
    
    questions.flatten!    
    
    # remove any items that do not have a question
#    questions = questions.select{|x| x[:question].present?}
    
    return questions
  end
  

  #######################################
  ## calculate how many questions are in this array of question categories
  ## - have to look for sub categories in each category
  #######################################
  def self.number_questions(question_categories)
    num = 0
    if question_categories.present?
      question_categories.each do |qc|
        num += qc[:questions].length
      
        num += number_questions(qc[:sub_categories]) if qc[:sub_categories].present?
      end
    end
    return num
  end


  
  
  
  #######################################
  ## load question categories, quetsions and pairings 
  ## from csv file
  #######################################
  def self.process_csv_upload(file, delete_first=false)
		start = Time.now
    infile = file.read
    n, msg = 0, ""
    idx_parent_name = 0
    idx_parent_sort = 1
    idx_parent_is_common = 2
    idx_child_name = 3
    idx_child_sort = 4
    idx_child_is_common = 5
    idx_type = 6
    idx_exists = 7
    idx_question = 8
    idx_question_sort = 9
    idx_question_evidence = 10
    idx_venue_name = 11
    current_parent, current_child, current_venue = nil

		original_locale = I18n.locale
    I18n.locale = :en

    disabilities = Disability.all


		QuestionCategory.transaction do
		  if delete_first
        puts "******** deleting all questions on record first"
        # quicker to do delete all instead of destroy        
        QuestionCategory.delete_all
        QuestionCategoryTranslation.delete_all
        Question.delete_all
        QuestionTranslation.delete_all
        QuestionPairing.delete_all
        QuestionPairingTranslation.delete_all
        PlaceEvaluation.delete_all
        PlaceEvaluationAnswer.delete_all

        connection = ActiveRecord::Base.connection
        ActiveRecord::Base.connection.execute("truncate disabilities_question_pairings;")        
        
		  end
		
		
		  CSV.parse(infile) do |row|
        question = nil
        startRow = Time.now
		    n += 1
        puts "@@@@@@@@@@@@@@@@@@ processing row #{n}"

        if n > 1
          # get question category
          # if the name does not match the last rows, create it if necessary
          if current_parent.nil? || current_parent[:name] != row[idx_parent_name].strip
            if row[idx_parent_name].blank?
	      		  msg = "Row #{n}: Parent Category Name is not provided"
			        raise ActiveRecord::Rollback
	      		  return msg
            end

          	puts "******** having to get parent: #{row[idx_parent_name]}"
            # need to create new question category or get it from db if already exists
            current_parent = get_category(row[idx_parent_name], row[idx_parent_sort], row[idx_parent_is_common])
          end

          if current_parent.blank? || current_parent.id.blank?
	    		  msg = "Row #{n}: Could not find/create parent"
			      raise ActiveRecord::Rollback
	    		  return msg
          end

        	puts "******** - parent: #{current_parent.id}; #{current_parent[:name]}"
          
          # get child question category if present
          if row[idx_child_name].present?
          	puts "******** child exists!"
            if current_child.nil? || current_child[:name] != row[idx_child_name].strip
              if row[idx_parent_name].blank?
	        		  msg = "Row #{n}: Child Category Name is not provided"
			          raise ActiveRecord::Rollback
	        		  return msg
              end

            	puts "******** - having to get child: #{row[idx_child_name]}"
              # need to create new question category or get it from db if already exists
              current_child = get_category(row[idx_child_name], row[idx_child_sort], row[idx_child_is_common], current_parent.id)

              if current_child.blank? || current_child.id.blank?
          		  msg = "Row #{n}: Could not find/create child"
		            raise ActiveRecord::Rollback
          		  return msg
              end
            end
          	puts "******** - child: #{current_child.id}; #{current_child[:name]}"
          else
            current_child = nil
          end

          # see if question already on file
          if row[idx_question].blank?
      		  msg = "Row #{n}: Question is not provided"
	          raise ActiveRecord::Rollback
      		  return msg
          end 
          
        	puts "******** geting question: #{row[idx_question]}"
          question = get_question(row[idx_question])

          if question.blank? || question.id.blank?
      		  msg = "Row #{n}: Could not find/create question"
	          raise ActiveRecord::Rollback
      		  return msg
          end
          
          # create pairing
        	puts "******** creating pairing"
          qc_id = current_child.blank? ? current_parent.id : current_child.id
          evidence = row[idx_question_evidence].present? ? row[idx_question_evidence].strip : nil
          qp = QuestionPairing.create(
                :question_category_id => qc_id, 
                :question_id => question.id, 
                :sort_order => row[idx_question_sort], 
                :is_exists => row[idx_exists].present? && row[idx_exists].to_s == '1' ? true : false
              )
          
          I18n.available_locales.each do |locale|
            qp.question_pairing_translations.create(:locale => locale, :evidence => evidence)
          end
         
          # add disability types if needed
          types = row[idx_type].present? ? row[idx_type].split(',') : nil
        	puts "******** question pairing already has disability types: '#{qp.disabilities.map{|x| x.code}}'"
          if types.blank?
      		  msg = "Row #{n}: Could not find disability type"
	          raise ActiveRecord::Rollback
      		  return msg
          else
            types.each do |type|
            	puts "******** - checking question pairing for disability type: #{type}"
              # find match and then add if not already assigned to question pairing
              dis_index = disabilities.index{|x| x.code == type}
              if dis_index.present? && qp.disabilities.index{|x| disabilities[dis_index].id == x.id}.blank?
              	puts "******** -- adding"
                qp.disabilities << disabilities[dis_index]
              end
            end
          end
          
         
          # if venue provided, add question category id to venue
          if (current_venue.blank? && row[idx_venue_name].present?) || (current_venue.present? && current_venue[:name] != row[idx_venue_name].strip)
          	puts "******** having to get venue: #{row[idx_venue_name]}"
            current_venue = get_venue(row[idx_venue_name])

            if current_venue.blank?
        		  msg = "Row #{n}: Could not find venue - make sure the venue already exists in the system"
		          raise ActiveRecord::Rollback
        		  return msg
            end
          elsif row[idx_venue_name].blank?
            current_venue = nil
          end
          
          if current_venue.present?
          	puts "******** adding question category id to venue: #{row[idx_venue_name]}; #{current_venue.inspect}"
            current_venue.question_category_id = current_parent.id
            current_venue.save
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
  # get question category and if not exist, create it
  def self.get_category(name, sort, is_common, parent_id=nil)
    qc = nil
    name.strip! if name.present?
    sort.strip! if sort.present?
    is_common.strip! if is_common.present?
    

    x = select('question_categories.id').includes(:question_category_translations)
          .where(:question_categories => {:sort_order => sort, :is_common => is_common, :ancestry => nil}, :question_category_translations => {:locale => I18n.locale, :name => name})
          
    qc = x.first if x.present?
    
    if qc.nil?
      qc = QuestionCategory.create(:is_common => is_common, :sort_order => sort)
      I18n.available_locales.each do |locale|
        qc.question_category_translations.create(:locale => locale, :name => name)
      end
      if parent_id.present?
        qc.parent_id = parent_id
        qc.save
      end
      qc[:name] = name
    end
    
    return qc
  end

  # get question and if not exist, create it
  def self.get_question(name)
    q = nil
    name.strip! if name.present?

    x = Question.select('questions.id').includes(:question_translations)
          .where(:question_translations => {:locale => I18n.locale, :name => name})
          
    q = x.first if x.present?
    
    if q.nil?
      q = Question.create
      I18n.available_locales.each do |locale|
        q.question_translations.create(:locale => locale, :name => name)
      end
    end
    
    return q
  end

  # get venue category
  def self.get_venue(name)
    v = nil
    name.strip! if name.present?

    x = Venue.includes(:venue_translations)
          .where(:venue_translations => {:locale => I18n.locale, :name => name})
          
    if x.present?
      v = x.first 
      v[:name] = name
    end
    
    return v
  end

end
