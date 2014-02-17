class PlaceSummary < ActiveRecord::Base

  belongs_to :place
  
  attr_accessible :place_id, :summary_type, :summary_type_identifier, 
                  :data_type, :data_type_identifier, 
                  :score, :special_flag, :num_answers, :num_evaluations
  validates :place_id, :summary_type, :data_type, :presence => true
  
  SUMMARY_TYPES = {'overall' => 0, 'disability' => 1, 'instance' => 2}
  DATA_TYPES = {'overall' => 0, 'category' => 1}
  SAVE_TYPES = {'summary_overall' => 0, 'summary_category' => 1, 'disability_overall' => 2, 'disability_category' => 3, 'instance_overall' => 4, 'instance_category' => 5}

  # for the given place id, update the summary data
  def self.update_summaries(place_id, place_evaluation_id)
    if place_id.present? && place_evaluation_id.present?
      summaries = {'summary' => {'overall' => nil, 'categories' => nil}, 
                  'disability' => {'overall' => nil, 'categories' => nil}, 
                  'instance' => {'overall' => nil, 'categories' => nil}}
      
      PlaceSummary.transaction do

        # get all evaluations for this place
        evaluations = PlaceEvaluation.with_answers_for_summary(place_id)

        # get all questions
        questions = QuestionPairing.questions_for_summary
        
        disability_id = nil
              
        if evaluations.present? && questions.present?
          Rails.logger.debug "************* total evaluations found: #{evaluations.length}; total questions found = #{questions.length}"
          
          exists_question_ids = questions.select{|x| x.is_exists == true}.map{|x| x.id}
          req_accessibility_question_ids = questions.select{|x| x.required_for_accessibility == true}.map{|x| x.id}
          category_ids = questions.map{|x| x[:root_question_category_id]}.uniq

          ##############################
          # compute overall summary
          ##############################
          Rails.logger.debug "************* computing overall summary"
          summaries['summary']['overall'] = summarize_answers(evaluations, exists_question_ids, req_accessibility_question_ids)
          summaries['summary']['categories'] = summarize_category_answers(evaluations, questions, category_ids, exists_question_ids, req_accessibility_question_ids)
          Rails.logger.debug "/////////////////// summaries['summary']: #{summaries['summary']}"

          ##############################
          # compute summary for disability this eval belongs to
          # - pull out answers that are tied to for this evaluation
          ##############################
          record_evaluations = evaluations.select{|x| x.id == place_evaluation_id}
          Rails.logger.debug "************* record evaluations found: #{record_evaluations.length}"
          if record_evaluations.present?
            # - get the disability type for this evaluation
            disability_id = record_evaluations.first.disability_id
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
              # compute summary for disability 
              ##############################
              Rails.logger.debug "************* computing disability summary"
              summaries['disability']['overall'] = summarize_answers(filtered_evaluations, filtered_exists_question_ids, filtered_req_accessibility_question_ids)
              summaries['disability']['categories'] = summarize_category_answers(filtered_evaluations, filtered_questions, filtered_category_ids, filtered_exists_question_ids, filtered_req_accessibility_question_ids)
              Rails.logger.debug "/////////////////// summaries['disability']: #{summaries['disability']}"
              

              ##############################
              # compute summary for this evaluation
              ##############################
              Rails.logger.debug "************* computing instance summary"
              summaries['instance']['overall'] = summarize_answers(record_evaluations, filtered_exists_question_ids, filtered_req_accessibility_question_ids)
              summaries['instance']['categories'] = summarize_category_answers(record_evaluations, filtered_questions, filtered_category_ids, filtered_exists_question_ids, filtered_req_accessibility_question_ids)
              Rails.logger.debug "/////////////////// summaries['instance']: #{summaries['instance']}"

            end
          end
        end
        
        ##############################
        ##############################
        # save the summaries
        ##############################
        ##############################
        existing_summaries = PlaceSummary.where(:place_id => place_id)
        # summary
        # - overall
        save_summary(place_id, existing_summaries, summaries, SAVE_TYPES['summary_overall'], SUMMARY_TYPES['overall'], DATA_TYPES['overall'])
        # - category
        save_category_summary(place_id, existing_summaries, summaries, category_ids, SAVE_TYPES['summary_category'], SUMMARY_TYPES['overall'], DATA_TYPES['category'])

        # disability
        # - overall
        save_summary(place_id, existing_summaries, summaries, SAVE_TYPES['disability_overall'], SUMMARY_TYPES['disability'], DATA_TYPES['overall'], 
              {'disability_id' => disability_id, 'summary_type_identifier' => disability_id})
        # - category
        save_category_summary(place_id, existing_summaries, summaries, category_ids, SAVE_TYPES['disability_category'], SUMMARY_TYPES['disability'], DATA_TYPES['category'], 
              {'disability_id' => disability_id, 'summary_type_identifier' => disability_id})

        # instance
        # - overall
        save_summary(place_id, existing_summaries, summaries, SAVE_TYPES['instance_overall'], SUMMARY_TYPES['instance'], DATA_TYPES['overall'], 
            {'disability_id' => disability_id, 'summary_type_identifier' => place_evaluation_id})
        # - category
        save_category_summary(place_id, existing_summaries, summaries, category_ids, SAVE_TYPES['instance_category'], SUMMARY_TYPES['instance'], DATA_TYPES['category'], 
            {'disability_id' => disability_id, 'summary_type_identifier' => place_evaluation_id})

=begin
        if summaries['summary']['overall'].present?
          index = existing_summaries.index{|x| x.summary_type == SUMMARY_TYPES['overall'] && x.data_type == DATA_TYPES['overall']}
          x = nil
          if index.blank? 
            # create new record
            # record does not exist, so create it
            x = PlaceSummary.new
            x.place_id = place_id
            x.summary_type = SUMMARY_TYPES['overall'] 
            x.data_type = DATA_TYPES['overall']
          else
            x = existing_summaries[index]
          end
          summaries['summary']['overall'].keys.each do |key|
            x[key] = summaries['summary']['overall'][key]
          end
          x.save
        end
        
        # disability
        # - overall
        if summaries['disability']['overall'].present? && disability_id.present?
          index = existing_summaries.index{|x| x.summary_type == SUMMARY_TYPES['disability'] && 
                                                      x.summary_type_identifier == disability_id && 
                                                      x.data_type == DATA_TYPES['overall']}
          x = nil
          if index.blank? 
            # create new record
            # record does not exist, so create it
            x = PlaceSummary.new
            x.place_id = place_id
            x.summary_type = SUMMARY_TYPES['disability'] 
            x.summary_type_identifier = disability_id
            x.data_type = DATA_TYPES['overall']
          else
            x = existing_summaries[index]
          end
          summaries['disability']['overall'].keys.each do |key|
            x[key] = summaries['disability']['overall'][key]
          end
          x.save
        end


        # instance
        # - overall
        if summaries['instance']['overall'].present? && place_evaluation_id.present?
          index = existing_summaries.index{|x| x.summary_type == SUMMARY_TYPES['instance'] && 
                                                      x.summary_type_identifier == disability_id && 
                                                      x.data_type == DATA_TYPES['overall']}
          x = nil
          if index.blank? 
            # create new record
            # record does not exist, so create it
            x = PlaceSummary.new
            x.place_id = place_id
            x.summary_type = SUMMARY_TYPES['instance'] 
            x.summary_type_identifier = place_evaluation_id
            x.data_type = DATA_TYPES['overall']
          else
            x = existing_summaries[index]
          end
          summaries['instance']['overall'].keys.each do |key|
            x[key] = summaries['instance']['overall'][key]
          end
          x.save
        end
=end        
      end    
    end
  end


private

  # records: array of place_evaluation_answers
  # exists_questions_ids: array of ids to questions that have exists flag
  # req_accessibility_question_ids: array of ids to questions that have required for accessibility flag
  # returns: {score, special_flag, num_answers, num_evaluations}
  # - score = overall average of records passed in unless a special case was found
  # - special_flag = one of SUMMARY_ANSWERS values or nil; will be nil if score has value
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
        h['special_flag'] = PlaceEvaluation::SUMMARY_ANSWERS['not_accessible']
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
            h['special_flag'] = PlaceEvaluation::SUMMARY_ANSWERS['not_relevant']
          else
#            Rails.logger.debug "************ has no answers"
            h['special_flag'] = PlaceEvaluation::SUMMARY_ANSWERS['no_answer']
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
  # place_id: id of place to add summaries to
  # existing_summaries: all existing summaries on record for this place
  # summaries: hash of summary scores to save to database (see summarize_answers for hash format) 
  # type: SAVE_TYPES value to indicate which type of data to save
  # summary_type: SUMMARY_TYPES value to indicate the type of summary data
  # data_type: DATA_TYPES value to indicate the type of data
  def self.save_summary(place_id, existing_summaries, summaries, type, summary_type, data_type, options={})
    options['summary_type_identifier'] = nil if !options.has_key?('summary_type_identifier')
    options['data_type_identifier'] = nil if !options.has_key?('data_type_identifier')
    options['disability_id'] = nil if !options.has_key?('disability_id')
  
    Rails.logger.debug "*********************************"
    Rails.logger.debug "************* save_summary start"
    Rails.logger.debug "*********************************"

    Rails.logger.debug "************* existing_summaries.length = #{existing_summaries.length}; type = #{type}; disability id = #{options['disability_id']}"
    Rails.logger.debug "************* summary_type = #{summary_type}; summary type id = #{options['summary_type_identifier']} s type id class = #{options['summary_type_identifier'].class}"
    Rails.logger.debug "************* data_type = #{data_type}; data type id = #{options['data_type_identifier']}; d type id class = #{options['data_type_identifier'].class}"
    
    if summaries.present?
      Rails.logger.debug "************* - summary answers exist"

      answers = nil
      index = nil
      case type
        when 0 # summary overall
          index = existing_summaries.index{|x| x.summary_type == summary_type && x.data_type == data_type}
          answers = summaries['summary']['overall'] if summaries.has_key?('summary') && summaries['summary'].has_key?('overall')

        when 1 # summary category
          if options['data_type_identifier'].present?
            index = existing_summaries.index{|x| x.summary_type == summary_type && 
                                                      x.data_type == data_type && 
                                                      x.data_type_identifier == options['data_type_identifier']}
            answers = summaries['summary']['categories'][options['data_type_identifier'].to_s] if summaries.has_key?('summary') && summaries['summary'].has_key?('categories') && summaries['summary']['categories'].has_key?(options['data_type_identifier'].to_s)
          end

        when 2 # disability overall
          if options['disability_id'].present?
            index = existing_summaries.index{|x| x.summary_type == summary_type && 
                                                      x.summary_type_identifier == options['disability_id'] && 
                                                      x.data_type == data_type}
            answers = summaries['disability']['overall'] if summaries.has_key?('disability') && summaries['disability'].has_key?('overall')
          end

        when 3 # disability category
          if options['disability_id'].present? && options['data_type_identifier'].present?
            index = existing_summaries.index{|x| x.summary_type == summary_type && 
                                                      x.summary_type_identifier == options['disability_id'] && 
                                                      x.data_type == data_type && 
                                                      x.data_type_identifier == options['data_type_identifier']}
            answers = summaries['disability']['categories'][options['data_type_identifier'].to_s] if summaries.has_key?('disability') && summaries['disability'].has_key?('categories') && summaries['disability']['categories'].has_key?(options['data_type_identifier'].to_s)
          end

        when 4 # instance overall
          if options['disability_id'].present?
            index = existing_summaries.index{|x| x.summary_type == summary_type && 
                                                      x.summary_type_identifier == options['disability_id'] && 
                                                      x.data_type == data_type}
            answers = summaries['instance']['overall'] if summaries.has_key?('instance') && summaries['instance'].has_key?('overall')
          end

        when 5 # instance category
          if options['disability_id'].present? && options['data_type_identifier'].present?
            index = existing_summaries.index{|x| x.summary_type == summary_type && 
                                                      x.summary_type_identifier == options['disability_id'] && 
                                                      x.data_type == data_type && 
                                                      x.data_type_identifier == options['data_type_identifier']}
            answers = summaries['instance']['categories'][options['data_type_identifier'].to_s] if summaries.has_key?('instance') && summaries['instance'].has_key?('categories') && summaries['instance']['categories'].has_key?(options['data_type_identifier'].to_s)
          end        
      end

      Rails.logger.debug "************* - index = #{index}; answers = #{answers}"
  
      if answers.present?
        x = nil
        if index.blank? 
          # create new record
          # record does not exist, so create it
          x = PlaceSummary.new
          x.place_id = place_id
          x.summary_type = summary_type
          x.summary_type_identifier = options['summary_type_identifier']
          x.data_type = data_type
          x.data_type_identifier = options['data_type_identifier']
        else
          x = existing_summaries[index]
        end
        answers.keys.each do |key|
          x[key] = answers[key]
        end
        x.save
      end

  
    end
    Rails.logger.debug "*********************************"
    Rails.logger.debug "************* save_summary end"
    Rails.logger.debug "*********************************"
  end
  
  # save the summary data for each category
  def self.save_category_summary(place_id, existing_summaries, summaries, category_ids, type, summary_type, data_type, options={})
    if category_ids.present?
      category_ids.each do |category_id|
        options['data_type_identifier'] = category_id
        save_summary(place_id, existing_summaries, summaries, type, summary_type, data_type, options)      
      end
    end
  end  
end
