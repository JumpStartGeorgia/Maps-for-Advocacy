class VenueSummary < ActiveRecord::Base
  belongs_to :place
  
  attr_accessible :venue_id, :venue_category_id, :summary_type, :summary_type_identifier, 
                  :data_type, :data_type_identifier, :disability_id,
                  :score, :special_flag, :num_answers, :num_evaluations, 
                  :is_certified
  validates :summary_type, :data_type, :presence => true
  
  SPECIAL_FLAGS = {'not_accessible' => 0, 'no_answer' => 1, 'not_relevant' => 2}
  SUMMARY_TYPES = {'overall' => 0, 'disability' => 1}
  DATA_TYPES = {'overall' => 0, 'category' => 1}
  SAVE_TYPES = {'summary_overall' => 0, 'summary_category' => 1, 'disability_overall' => 2, 'disability_category' => 3}

  def to_summary_hash
    {
      'score' => self.score,
      'special_flag' => self.special_flag,
      'num_answers' => self.num_answers,
      'num_evaluations' => self.num_evaluations    
    }
  end

  def self.certified_venue(venue_id)
    where(:venue_id => venue_id, :is_certified => true)
  end
  
  def self.not_certified_venue(venue_id)
    where(:venue_id => venue_id, :is_certified => false)
  end
  
  def self.certified_venue_category(venue_category_id)
    where(:venue_category_id => venue_category_id, :is_certified => true)
  end
  
  def self.not_certified_venue_category(venue_category_id)
    where(:venue_category_id => venue_category_id, :is_certified => false)
  end
  

  ##################################
  ##################################
  ### summary stats 
  ##################################
  ##################################


  # get the overall stats for all places in a venue
  # - venue_id: id of venue or venue category
  # - is_category: is id for venue or venue category
  # return: {:certified => {:total => {:total => #, :disabilities => {1 => #, 2 => #, etc}, 
  #                         :accessible => {:total => #, :disabilities => {1 => #, 2 => #, etc}, 
  #                         :partial_accessible => ,
  #                         :not_accessible => },
  #           :public => {same format as certified}
  #         }
  def self.stats_overall_place_evaluation_results(venue_id, is_category=false)
    stats = {:certified => Hash.new, :public => Hash.new}
    data = {:total => 0, :disabilities => nil}
    summaries = where(:summary_type => SUMMARY_TYPES['overall'], :data_type => DATA_TYPES['overall'])
    disability_summaries = where(:summary_type => SUMMARY_TYPES['disability'], :data_type => DATA_TYPES['overall'])
    if is_category
      summaries = summaries.where(:venue_category_id => venue_id)
      disability_summaries = disability_summaries.where(:venue_category_id => venue_id)
    else
      summaries = summaries.where(:venue_id => venue_id)
      disability_summaries = disability_summaries.where(:venue_id => venue_id)
    end

    disabilities = Disability.is_active.select('id').map{|x| x.id}

    if summaries.present?
      # total
      stats[:certified][:total] = data.clone
      stats[:public][:total] = data.clone
      stats[:certified][:total][:total] = add_num_evaluations(summaries.select{|x| x.is_certified == true})
      stats[:public][:total][:total] = add_num_evaluations(summaries.select{|x| x.is_certified == false})

      # accessible
      stats[:certified][:accessible] = data.clone
      stats[:public][:accessible] = data.clone
      stats[:certified][:accessible][:total] = add_num_evaluations(summaries.select{|x| x.is_certified == true && x.score == PlaceEvaluation::ANSWERS['has_good']})
      stats[:public][:accessible][:total] = add_num_evaluations(summaries.select{|x| x.is_certified == false && x.score == PlaceEvaluation::ANSWERS['has_good']})
      
     
      # partial accessible
      stats[:certified][:partial_accessible] = data.clone
      stats[:public][:partial_accessible] = data.clone
      stats[:certified][:partial_accessible][:total] = add_num_evaluations(summaries.select{|x| x.is_certified == true && x.score.present? && x.score < PlaceEvaluation::ANSWERS['has_good']})
      stats[:public][:partial_accessible][:total] = add_num_evaluations(summaries.select{|x| x.is_certified == false && x.score.present? && x.score < PlaceEvaluation::ANSWERS['has_good']})
      
      
      # not accessible
      stats[:certified][:not_accessible] = data.clone
      stats[:public][:not_accessible] = data.clone
      stats[:certified][:not_accessible][:total] = add_num_evaluations(summaries.select{|x| x.is_certified == true && x.special_flag == SPECIAL_FLAGS['not_accessible']})
      stats[:public][:not_accessible][:total] = add_num_evaluations(summaries.select{|x| x.is_certified == false && x.special_flag == SPECIAL_FLAGS['not_accessible']})


      # - disabilities
      if disabilities.present? && disability_summaries.present?
        # initialize the hash
        stats[:certified][:total][:disabilities] = Hash.new
        stats[:public][:total][:disabilities] = Hash.new
        stats[:certified][:accessible][:disabilities] = Hash.new
        stats[:public][:accessible][:disabilities] = Hash.new
        stats[:certified][:partial_accessible][:disabilities] = Hash.new
        stats[:public][:partial_accessible][:disabilities] = Hash.new
        stats[:certified][:not_accessible][:disabilities] = Hash.new
        stats[:public][:not_accessible][:disabilities] = Hash.new

        disabilities.each do |disability_id|
          # total
          stats[:certified][:total][:disabilities][disability_id.to_s] = add_num_evaluations(disability_summaries.select{|x| x.is_certified == true && x.summary_type_identifier == disability_id})
          stats[:public][:total][:disabilities][disability_id.to_s] = add_num_evaluations(disability_summaries.select{|x| x.is_certified == false && x.summary_type_identifier == disability_id})

          # accessible
          stats[:certified][:accessible][:disabilities][disability_id.to_s] = add_num_evaluations(disability_summaries.select{|x| x.is_certified == true && x.score == PlaceEvaluation::ANSWERS['has_good'] && x.summary_type_identifier == disability_id})
          stats[:public][:accessible][:disabilities][disability_id.to_s] = add_num_evaluations(disability_summaries.select{|x| x.is_certified == false && x.score == PlaceEvaluation::ANSWERS['has_good'] && x.summary_type_identifier == disability_id})
          
         
          # partial accessible
          stats[:certified][:partial_accessible][:disabilities][disability_id.to_s] = add_num_evaluations(disability_summaries.select{|x| x.is_certified == true && x.score.present? && x.score < PlaceEvaluation::ANSWERS['has_good'] && x.summary_type_identifier == disability_id})
          stats[:public][:partial_accessible][:disabilities][disability_id.to_s] = add_num_evaluations(disability_summaries.select{|x| x.is_certified == false && x.score.present? && x.score < PlaceEvaluation::ANSWERS['has_good'] && x.summary_type_identifier == disability_id})
          
          
          # not accessible
          stats[:certified][:not_accessible][:disabilities][disability_id.to_s] = add_num_evaluations(disability_summaries.select{|x| x.is_certified == true && x.special_flag == SPECIAL_FLAGS['not_accessible'] && x.summary_type_identifier == disability_id})
          stats[:public][:not_accessible][:disabilities][disability_id.to_s] = add_num_evaluations(disability_summaries.select{|x| x.is_certified == false && x.special_flag == SPECIAL_FLAGS['not_accessible'] && x.summary_type_identifier == disability_id})
        end
      end
    end
    
    return stats
  end


  ##################################
  ##################################
  ## compute summaries
  ##################################
  ##################################

  # create the summaries for all venues and venue categories
  def self.create_all_summaries
    place_ids = PlaceEvaluation.select('distinct place_id').map{|x| x.place_id}
    if place_ids.present?
      # get venues for these places
      venue_ids = Place.where(:id => place_ids).select('distinct venue_id').map{|x| x.venue_id}
      if venue_ids.present?
        venue_ids.each do |venue_id|
          update_summaries(venue_id)
          update_certified_summaries(venue_id)
        end  
        
        # get venue category ids
        venue_category_ids = Venue.where(:id => venue_ids).select('distinct venue_category_id').map{|x| x.venue_category_id}
        if venue_category_ids.present?
          venue_category_ids.each do |venue_category_id|
            update_summaries(venue_category_id, true)
            update_certified_summaries(venue_category_id, true)
          end  
        end
      end
    end
  end



  # for the given place id, update the summary data
  # place_id: id of place to summarize evaluations for
  # place_evaluation_id: id of evaluation to focus summary's on
  # - if place_evaluation_id not provided, then compute instance summary for every evaluation
  def self.update_summaries(venue_id, is_category=false)
    Rails.logger.debug "*****************************************"
    Rails.logger.debug "************* update_summaries: start"
    Rails.logger.debug "*****************************************"
    if venue_id.present?
      VenueSummary.transaction do

        # get all evaluations for this venue
        evaluations = nil
        if is_category
          evaluations = PlaceEvaluation.with_answers_for_venue_category_summary(venue_id)
        else
          evaluations = PlaceEvaluation.with_answers_for_venue_summary(venue_id)
        end

        # get all questions
        questions = QuestionPairing.questions_for_summary
        
        disability_id = nil
              
        if evaluations.present? && questions.present?
          Rails.logger.debug "************* total evaluations found: #{evaluations.length}; total questions found = #{questions.length}"
          
          exists_question_ids = questions.select{|x| x.is_exists == true}.map{|x| x.id}
          req_accessibility_question_ids = questions.select{|x| x.required_for_accessibility == true}.map{|x| x.id}
          category_ids = questions.map{|x| x[:root_question_category_id]}.uniq
          
          # get all existing summaries on record
          existing_summaries = nil
          if is_category
            existing_summaries = not_certified_venue_category(venue_id)
          else
            existing_summaries = not_certified_venue(venue_id)
          end

          # get all unique place ids
          place_ids = evaluations.map{|x| x.place_id}.uniq

          # get all unique disability ids
          disability_ids = evaluations.map{|x| x.disability_id}.uniq

          if place_ids.present? && disability_ids.present?

            disability_ids.each do |disability_id|
              Rails.logger.debug "************* disability id = #{disability_id}"

              # disability ids in the questions are surrounded by a separator so that we can test for exact match
              # - i.e., do not want a test of 1 to return true for 12
              # - so instead looking for +1+ and this will return false for +12+
              question_disability_filter = QuestionPairing::DISABILITY_ID_SEPARATOR.clone
              question_disability_filter << disability_id.to_s
              question_disability_filter << QuestionPairing::DISABILITY_ID_SEPARATOR
              # - pull out questions that are for this disability
              Rails.logger.debug "************* question_disability_filter: #{question_disability_filter}"
              filtered_questions = questions.select{|x| x[:disability_ids].index(question_disability_filter).present?}
              # - pull out evaluations that are for this disability
              filtered_evaluations = evaluations.select{|x| x.disability_id == disability_id}

              Rails.logger.debug "************* filtered evals found: #{filtered_evaluations.length}; filtered question found: #{filtered_questions.length}"
              if filtered_evaluations.present? && filtered_questions.present?

                filtered_exists_question_ids = filtered_questions.select{|x| x.is_exists == true}.map{|x| x.id}
                filtered_req_accessibility_question_ids = filtered_questions.select{|x| x.required_for_accessibility == true}.map{|x| x.id}
                filtered_category_ids = filtered_questions.map{|x| x[:root_question_category_id]}.uniq

                ##############################
                # save summary for disability
                ##############################
                Rails.logger.debug "************* creating disability summary"
                # - overall
                save_summary(venue_id, 
                              existing_summaries, 
                              summarize_answers(filtered_evaluations, filtered_exists_question_ids, filtered_req_accessibility_question_ids), 
                              SAVE_TYPES['disability_overall'], SUMMARY_TYPES['disability'], DATA_TYPES['overall'], 
                              is_category,                                
                              {'disability_id' => disability_id, 'summary_type_identifier' => disability_id})

                # - category
                save_category_summary(venue_id, 
                                      existing_summaries, 
                                      summarize_category_answers(filtered_evaluations, filtered_questions, filtered_category_ids, filtered_exists_question_ids, filtered_req_accessibility_question_ids), 
                                      category_ids, 
                                      SAVE_TYPES['disability_category'], SUMMARY_TYPES['disability'], DATA_TYPES['category'], 
                                      is_category,                                
                                      {'disability_id' => disability_id, 'summary_type_identifier' => disability_id})
              end
            end
            
            
            ##############################
            # save summary for overall
            ##############################
            Rails.logger.debug "************* computing overall summary using #{evaluations.map{|x| x.id}.uniq.length} evaluations"
            save_summary(venue_id, 
                          existing_summaries, 
                          summarize_answers(evaluations, exists_question_ids, req_accessibility_question_ids), 
                          SAVE_TYPES['summary_overall'], SUMMARY_TYPES['overall'], DATA_TYPES['overall'], 
                          is_category)

            save_category_summary(venue_id, 
                                  existing_summaries, 
                                  summarize_category_answers(evaluations, questions, category_ids, exists_question_ids, req_accessibility_question_ids), 
                                  category_ids, 
                                  SAVE_TYPES['summary_category'], SUMMARY_TYPES['overall'], DATA_TYPES['category'], 
                                  is_category)
          end      
        end      
      end
    end
  end    


  # for the given venue id, update the summary data for certified evaluations
  # venue_id: id of venue or vendue_category to summarize evaluations for
  # is_category: indicaties if the id belongs to venue or venue category
  def self.update_certified_summaries(venue_id, is_category=false)
    Rails.logger.debug "*****************************************"
    Rails.logger.debug "************* update_certified_summaries: start"
    Rails.logger.debug "*****************************************"
    if venue_id.present?
      VenueSummary.transaction do

        # get all evaluations for this venue
        evaluations = nil
        if is_category
          evaluations = PlaceEvaluation.with_answers_for_venue_category_summary(venue_id, is_certified: true)
        else
          evaluations = PlaceEvaluation.with_answers_for_venue_summary(venue_id, is_certified: true)
        end

        # get all questions
        questions = QuestionPairing.questions_for_summary
        
        disability_id = nil
              
        if evaluations.present? && questions.present?
          Rails.logger.debug "************* total evaluations found: #{evaluations.length}; total questions found = #{questions.length}"
          
          exists_question_ids = questions.select{|x| x.is_exists == true}.map{|x| x.id}
          req_accessibility_question_ids = questions.select{|x| x.required_for_accessibility == true}.map{|x| x.id}
          category_ids = questions.map{|x| x[:root_question_category_id]}.uniq
          
          # get all existing summaries on record
          existing_summaries = nil
          if is_category
            existing_summaries = certified_venue_category(venue_id)
          else
            existing_summaries = certified_venue(venue_id)
          end

          # get all unique place ids
          place_ids = evaluations.map{|x| x.place_id}.uniq

          # get all unique disability ids
          disability_ids = evaluations.map{|x| x.disability_id}.uniq

          if place_ids.present? && disability_ids.present?

            # to store the last evaluation of each place from each disability
            latest_evaluations = []
          
            disability_ids.each do |disability_id|
              Rails.logger.debug "************* disability id = #{disability_id}"

              disability_evaluations = []
          
              # disability ids in the questions are surrounded by a separator so that we can test for exact match
              # - i.e., do not want a test of 1 to return true for 12
              # - so instead looking for +1+ and this will return false for +12+
              question_disability_filter = QuestionPairing::DISABILITY_ID_SEPARATOR.clone
              question_disability_filter << disability_id.to_s
              question_disability_filter << QuestionPairing::DISABILITY_ID_SEPARATOR
              # - pull out questions that are for this disability
              Rails.logger.debug "************* question_disability_filter: #{question_disability_filter}"
              filtered_questions = questions.select{|x| x[:disability_ids].index(question_disability_filter).present?}
              # - pull out evaluations that are for this disability
              filtered_evaluations = evaluations.select{|x| x.disability_id == disability_id}

              Rails.logger.debug "************* filtered evals found: #{filtered_evaluations.length}; filtered question found: #{filtered_questions.length}"
              if filtered_evaluations.present? && filtered_questions.present?

                filtered_exists_question_ids = filtered_questions.select{|x| x.is_exists == true}.map{|x| x.id}
                filtered_req_accessibility_question_ids = filtered_questions.select{|x| x.required_for_accessibility == true}.map{|x| x.id}
                filtered_category_ids = filtered_questions.map{|x| x[:root_question_category_id]}.uniq

                ##############################
                # save summary for disability
                # - just use the latest evaluation from each place in this disability
                ##############################
                Rails.logger.debug "************* creating disability summary"

                place_ids.each do |place_id|
                  latest_id = filtered_evaluations.select{|x| x.place_id == place_id}.map{|x| x.id}.max
                  if latest_id.present?
                    disability_evaluations << filtered_evaluations.select{|x| x.id == latest_id} 
                  end
                end
                
                disability_evaluations.flatten!
                Rails.logger.debug "************* found #{disability_evaluations.map{|x| x.id}.uniq.length} evaluations for this disabilty"

                if disability_evaluations.present?
                  latest_evaluations << disability_evaluations
                
                  # - overall
                  save_summary(venue_id, 
                                existing_summaries, 
                                summarize_answers(disability_evaluations, filtered_exists_question_ids, filtered_req_accessibility_question_ids), 
                                SAVE_TYPES['disability_overall'], SUMMARY_TYPES['disability'], DATA_TYPES['overall'], 
                                is_category,                                
                                {'disability_id' => disability_id, 'summary_type_identifier' => disability_id, 'is_certified' => true})

                  # - category
                  save_category_summary(venue_id, 
                                        existing_summaries, 
                                        summarize_category_answers(disability_evaluations, filtered_questions, filtered_category_ids, filtered_exists_question_ids, filtered_req_accessibility_question_ids), 
                                        category_ids, 
                                        SAVE_TYPES['disability_category'], SUMMARY_TYPES['disability'], DATA_TYPES['category'], 
                                        is_category,                                
                                        {'disability_id' => disability_id, 'summary_type_identifier' => disability_id, 'is_certified' => true})
                end                  
              end
            end
            
            
            ##############################
            # save summary for overall
            ##############################
            if latest_evaluations.present?
              latest_evaluations.flatten!              

              Rails.logger.debug "************* computing overall summary using #{latest_evaluations.map{|x| x.id}.uniq.length} evaluations"
              save_summary(venue_id, 
                            existing_summaries, 
                            summarize_answers(latest_evaluations, exists_question_ids, req_accessibility_question_ids), 
                            SAVE_TYPES['summary_overall'], SUMMARY_TYPES['overall'], DATA_TYPES['overall'], 
                            is_category,                                
                            {'is_certified' => true})

              save_category_summary(venue_id, 
                                    existing_summaries, 
                                    summarize_category_answers(latest_evaluations, questions, category_ids, exists_question_ids, req_accessibility_question_ids), 
                                    category_ids, 
                                    SAVE_TYPES['summary_category'], SUMMARY_TYPES['overall'], DATA_TYPES['category'], 
                                    is_category,                                
                                    {'is_certified' => true})
              
            end
          end      
        end      
      end
    end
  end    


private

  # records: array of place_evaluation_answers
  # exists_questions_ids: array of ids to questions that have exists flag
  # req_accessibility_question_ids: array of ids to questions that have required for accessibility flag
  # returns: {score, special_flag, num_answers, num_evaluations}
  # - score = overall average of records passed in unless a special case was found
  # - special_flag = one of SPECIAL_FLAGS values or nil; will be nil if score has value
  # - num_answers = number of answers that exist
  # - num_evaluations = number of evaluations that exist
  def self.summarize_answers(records, exists_question_ids, req_accessibility_question_ids)
    h = {'score' => nil, 'special_flag' => nil, 'num_answers' => nil, 'num_evaluations' => nil}
    
    if records.present?
      h['num_evaluations'] = records.map{|x| x.id}.uniq.length
      h['num_answers'] = records.select{|x| x[:answer] > PlaceEvaluation::ANSWERS['no_answer']}.length

      # see if any required accessibility questions have 'needs' answer
      if req_accessibility_question_ids.present? && 
            records.index{|x| req_accessibility_question_ids.index(x[:question_pairing_id]).present? && x[:answer] == PlaceEvaluation::ANSWERS['needs']}.present?
#        Rails.logger.debug "************ found an answer that is 'needs' for a required accessibility question -> not accessible"
        # found an answer that is 'needs' for a required accessibility question
        # -> not accessible
        h['special_flag'] = SPECIAL_FLAGS['not_accessible']
      else
        # get average of answers that are not:
        # - for exists questions 
        # - do not have answers of not relevant or not answerd
        filtered_records = records.select{|x| (exists_question_ids.nil? || exists_question_ids.index(x[:question_pairing_id]).nil?) && 
            [PlaceEvaluation::ANSWERS['no_answer'], PlaceEvaluation::ANSWERS['not_relevant']].index(x[:answer]).nil?}
        if filtered_records.present?
          answers = filtered_records.map{|x| x[:answer]}
          avg = answers.sum / answers.size.to_f
          h['score'] = avg
        else
          if records.select{|x| x[:answer] == PlaceEvaluation::ANSWERS['not_relevant']}.present?
#            Rails.logger.debug "************ has not relevant only answers"
            h['special_flag'] = SPECIAL_FLAGS['not_relevant']
          else
#            Rails.logger.debug "************ has no answers"
            h['special_flag'] = SPECIAL_FLAGS['no_answer']
          end
        end        
      end
    end

#    Rails.logger.debug "/////////////////// summary values: #{h}"
    return h
  end
  
  
  # records: array of place_evaluation_answers
  # questions: array of questions
  # category_ids: array of unique question category ids
  # exists_questions_ids: array of ids to questions that have exists flag
  # req_accessibility_question_ids: array of ids to questions that have required for accessibility flag
  # returns: {category_id => {summary answers}, category_id => {summary answers}}
  # - category_id = id of question category
  # - summary answers = hash of summary answers for the question category (see summarize_answers for hash that is returned)
  def self.summarize_category_answers(records, questions, category_ids, exists_question_ids, req_accessibility_question_ids)
    answers = Hash.new
    
    if category_ids.present?
      category_ids.each do |category_id|
        question_pairing_ids = questions.select{|x| x.root_question_category_id == category_id}.map{|x| x.id}
  
        if question_pairing_ids.present?
          category_records = records.select{|x| question_pairing_ids.index(x[:question_pairing_id]).present? }
          if category_records.present?
              answers[category_id.to_s] = summarize_answers(category_records, exists_question_ids, req_accessibility_question_ids)
          end
        end
      end    
    end
    
    return answers
  end


  # create a new summary record, or if it already exists, update it
  # is_category: indicates if this is venue or venue category
  # venue_id: id of place to add summaries to
  # existing_summaries: all existing summaries on record for this place
  # summaries: hash of summary scores to save to database (see summarize_answers for hash format) 
  # type: SAVE_TYPES value to indicate which type of data to save
  # summary_type: SUMMARY_TYPES value to indicate the type of summary data
  # data_type: DATA_TYPES value to indicate the type of data
  # options:
  # - is_certified: whether this summary is for a certified evaluation
  # - summary_type_identifier: id of summary type record
  # - data_type_identifier: id of data type record
  # - disability_id: id of disability summary is for
  def self.save_summary(venue_id, existing_summaries, summaries, type, summary_type, data_type, is_category=false, options={})
    summary = nil
    options['summary_type_identifier'] = nil if !options.has_key?('summary_type_identifier')
    options['data_type_identifier'] = nil if !options.has_key?('data_type_identifier')
    options['disability_id'] = nil if !options.has_key?('disability_id')
    options['is_certified'] = false if !options.has_key?('is_certified')
  
    puts "*********************************"
    puts "************* save_summary start"
    puts "*********************************"

    puts "************* existing_summaries.length = #{existing_summaries.length}; type = #{type}"
    puts "************* is certified = #{options['is_certified']}; disability id = #{options['disability_id']}"
    puts "************* summary_type = #{summary_type}; summary type id = #{options['summary_type_identifier']}; s type id class = #{options['summary_type_identifier'].class}"
    puts "************* data_type = #{data_type}; data type id = #{options['data_type_identifier']}; d type id class = #{options['data_type_identifier'].class}"
    
    if summaries.present?
      puts "************* - summary answers exist"

      answers = nil
      index = nil
      case type
        when 0 # summary overall
          index = existing_summaries.index{|x| x.summary_type == summary_type && x.data_type == data_type}
          answers = summaries

        when 1 # summary category
          if options['data_type_identifier'].present?
            index = existing_summaries.index{|x| x.summary_type == summary_type && 
                                                      x.data_type == data_type && 
                                                      x.data_type_identifier == options['data_type_identifier'] &&
                                                      x.is_certified == options['is_certified']}
            answers = summaries[options['data_type_identifier'].to_s] if summaries.has_key?(options['data_type_identifier'].to_s)
          end

        when 2 # disability overall
          if options['disability_id'].present?
            index = existing_summaries.index{|x| x.summary_type == summary_type && 
                                                      x.summary_type_identifier == options['disability_id'] && 
                                                      x.data_type == data_type &&
                                                      x.is_certified == options['is_certified']}
            answers = summaries
          end

        when 3 # disability category
          if options['disability_id'].present? && options['data_type_identifier'].present?
            index = existing_summaries.index{|x| x.summary_type == summary_type && 
                                                      x.summary_type_identifier == options['disability_id'] && 
                                                      x.data_type == data_type && 
                                                      x.data_type_identifier == options['data_type_identifier'] &&
                                                      x.is_certified == options['is_certified']}
            answers = summaries[options['data_type_identifier'].to_s] if summaries.has_key?(options['data_type_identifier'].to_s)
          end

      end

      puts "************* - index = #{index}; answers = #{answers}"
  
      if answers.present?
        if index.blank? 
          # create new record
          # record does not exist, so create it
          summary = VenueSummary.new
          if is_category
            summary.venue_category_id = venue_id
          else
            summary.venue_id = venue_id
          end
          summary.summary_type = summary_type
          summary.summary_type_identifier = options['summary_type_identifier']
          summary.data_type = data_type
          summary.data_type_identifier = options['data_type_identifier']
          summary.disability_id = options['disability_id']
          summary.is_certified = options['is_certified']
        else
          summary = existing_summaries[index]
        end
        answers.keys.each do |key|
          summary[key] = answers[key]
        end
        summary.save
      end

  
    end
    puts "*********************************"
    puts "************* save_summary end"
    puts "*********************************"
    return summary
  end
  
  # save the summary data for each category
  def self.save_category_summary(venue_id, existing_summaries, summaries, category_ids, type, summary_type, data_type, is_category=false, options={})
    summary = []
    if category_ids.present?
      category_ids.each do |category_id|
        options['data_type_identifier'] = category_id
        summary << save_summary(venue_id, existing_summaries, summaries, type, summary_type, data_type, is_category, options)      
      end
    end
    return summary
  end 


  # sum up all of the num_evaluations values in the venue_summary array
  # - summaries: array of venue_summary objects
  def self.add_num_evaluations(summaries)
    num = 0
    
    if summaries.present?
      num = summaries.map{|x| x.num_evaluations}.sum
    end
    
    return num
  end


end



