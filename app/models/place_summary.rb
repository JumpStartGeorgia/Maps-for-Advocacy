class PlaceSummary < ActiveRecord::Base

  belongs_to :place
  
  attr_accessible :place_id, :summary_type, :summary_type_identifier, 
                  :data_type, :data_type_identifier, :disability_id,
                  :score, :special_flag, :num_answers, :num_evaluations, 
                  :is_certified, :percentage, :num_yes, :num_no
  validates :place_id, :summary_type, :data_type, :presence => true
  
  SUMMARY_TYPES = {'overall' => 0, 'disability' => 1, 'instance' => 2}
  DATA_TYPES = {'overall' => 0, 'category' => 1, 'question' => 2}
  SAVE_TYPES = {'summary_overall' => 0, 'summary_category' => 1, 
                'disability_overall' => 2, 'disability_category' => 3, 
                'instance_overall' => 4, 'instance_category' => 5,
                'summary_question' => 6, 'disability_question' => 7, 'instance_question' => 8}

  def to_summary_hash
    {
      'score' => self.score,
      'percentage' => self.percentage,
      'special_flag' => self.special_flag,
      'num_answers' => self.num_answers,
      'num_evaluations' => self.num_evaluations,
      'num_yes' => self.num_yes,
      'num_no' => self.num_no
    }
  end
  
  def self.certified(place_id)
    where(:place_id => place_id, :is_certified => true)
  end
  
  def self.not_certified(place_id)
    where(:place_id => place_id, :is_certified => false)
  end
  
  
  
  def self.overall_summaries_for_places(place_ids)
    if place_ids.present?
      where(:place_id => place_ids, :summary_type => SUMMARY_TYPES['overall'], :data_type => DATA_TYPES['overall'])
    end
  end
  
  # get summary data for a place/disability
  # return: {
  #  'overall' => {overall => {score, special_flag, num_evaluations, num_answers}, cat_id1 => {score, special_flag, num_evaluations, num_answers}, cat_id2, etc},
  #  'evaluations' => [{id, overall => {score, special_flag, num_evaluations, num_answers}, cat_id1 => {score, special_flag, num_evaluations, num_answers}, cat_id2, etc},etc]  
  # }
  def self.for_place_disablity(place_id, options={})
    options[:disability_id] = nil if !options.has_key?(:disability_id)
    options[:is_certified] = false if !options.has_key?(:is_certified)

    summary = Hash.new
    summary['overall'] = nil
    summary['evaluations'] = []
    
    if place_id.present?
      summaries = nil
      if options[:disability_id].present?
        summaries = where(:place_id => place_id, :disability_id => options[:disability_id], :is_certified => options[:is_certified])
                    .order('summary_type, data_type')
      else
        # no disability id so get overall result
        summaries = where(:place_id => place_id, :summary_type => SUMMARY_TYPES['overall'], :is_certified => options[:is_certified])
                    .order('summary_type, data_type')
      end

      if summaries.present?
        summary['overall'] = Hash.new
        
        if options[:disability_id].present?
          ################
          # add the overall summaries
          ################
          summary['overall'] = format_summary_hash(summaries.select{|x| x.summary_type == SUMMARY_TYPES['disability']})
      
          ################
          # add the instance summaries
          ################
          instances = summaries.select{|x| x.summary_type == SUMMARY_TYPES['instance']}
          if instances.present?
            instance_ids = instances.map{|x| x.summary_type_identifier}.uniq
            if instance_ids.present?
              instance_ids.each do |instance_id|          
                h = format_summary_hash(instances.select{|x| x.summary_type_identifier == instance_id})
                if h.length > 0
                  h['id'] = instance_id
                  summary['evaluations'] << h               
                end          
              end
            end
          end
        else
          ################
          # add the overall summaries
          ################
          summary['overall'] = format_summary_hash(summaries)
        end
      end
    end

    return summary
  end

  ########################### 
  ## overall stats
  ###########################
  # num of places with evals
  def self.overall_places_with_evals
     where(:summary_type => SUMMARY_TYPES['overall'], :data_type => DATA_TYPES['overall']).count(:place_id, :distinct => true)
  end

  # overall public eval results
  # - take sum of all public instance evals
  def self.overall_public_results
    counts = {'count' => 0, 'num_yes' => 0, 'num_no' => 0}
    x = find_by_sql(['select count(*) as c, sum(num_yes) as y, sum(num_no) as n from place_summaries where is_certified = 0 and summary_type = ? and data_type = ?', SUMMARY_TYPES['instance'], DATA_TYPES['overall']])
    if x.present?
      counts['count'] = x[0]['c']
      counts['num_yes'] = x[0]['y'].to_i
      counts['num_no'] = x[0]['n'].to_i
    end

    return counts
  end
  
  # overall certified eval results
  # - only take sum of disability summaries so that only the last cert eval of each place is used
  def self.overall_certified_results
    counts = {'count' => 0, 'num_yes' => 0, 'num_no' => 0}
    x = find_by_sql(['select count(*) as c, sum(num_yes) as y, sum(num_no) as n from place_summaries where is_certified = 1 and summary_type = ? and data_type = ?', SUMMARY_TYPES['disability'], DATA_TYPES['overall']])
    if x.present?
      counts['count'] = x[0]['c']
      counts['num_yes'] = x[0]['y'].to_i
      counts['num_no'] = x[0]['n'].to_i
    end

    return counts
  end

  # get the overall results by type
  def self.overall_results_by_type
    results = []
    public_counts = find_by_sql(['select disability_id, count(*) as c, sum(num_yes) as y, sum(num_no) as n from place_summaries where is_certified = 0 and is_certified = 0 and summary_type = ? and data_type = ? group by disability_id', SUMMARY_TYPES['instance'], DATA_TYPES['overall']])
    cert_counts =   find_by_sql(['select disability_id, count(*) as c, sum(num_yes) as y, sum(num_no) as n from place_summaries where is_certified = 1 and is_certified = 1 and summary_type = ? and data_type = ? group by disability_id', SUMMARY_TYPES['disability'], DATA_TYPES['overall']])

    if public_counts.present? || cert_counts.present?
      # get disability into
      dis_ids = []
      dis_ids << public_counts.map{|x| x['disability_id']}.uniq
      dis_ids << cert_counts.map{|x| x['disability_id']}.uniq
      disabilities = Disability.is_active.sorted.where(:id => dis_ids.flatten.uniq)

      count = {'count' => 0, 'num_yes' => 0, 'num_no' => 0}
      disabilities.each do |disability|
        # reformat to: {public_count, certified_count, total_count }
        h = {'name' => disability.name, 'public' => count.dup, 'certified' => count.dup}
        # get public counts
        match = public_counts.select{|x| x['disability_id'] == disability.id}.first
        if match.present?
          h['public']['count'] = match['c']
          h['public']['num_yes'] = match['y'].to_i
          h['public']['num_no'] = match['n'].to_i
        end        

        # get certified counts
        match = cert_counts.select{|x| x['disability_id'] == disability.id}.first
        if match.present?
          h['certified']['count'] = match['c']
          h['certified']['num_yes'] = match['y'].to_i
          h['certified']['num_no'] = match['n'].to_i
        end        
        results << h
      end
    end

    return results
  end

  ########################### 
  ## update stats
  ###########################


  # reset the summaries for all places that are evaluated
  def self.reset_all_place_summaries  
    PlaceSummary.transaction do 
      # remove all existing summaries
      destroy_all

      # for each place that has an evaluation, build the summaries
      PlaceEvaluation.select('distinct place_id').map{|x| x.place_id}.each do |place_id|
        puts "place_id = #{place_id}"
        update_summaries(place_id)
        update_certified_summaries(place_id)
      end
    end
  end


  # for the given place id, update the public summary data
  # place_id: id of place to summarize evaluations for
  # place_evaluation_id: id of evaluation to focus summary's on
  # - if place_evaluation_id not provided, then compute instance summary for every evaluation
  def self.update_summaries(place_id, place_evaluation_id=nil)
    Rails.logger.debug "*****************************************"
    Rails.logger.debug "************* update_summaries: start"
    Rails.logger.debug "*****************************************"
    if place_id.present?
      PlaceSummary.transaction do

        # get all evaluations for this place
        evaluations = PlaceEvaluation.with_answers_for_summary(place_id, is_certified: false, place_evaluation_id: place_evaluation_id)

        # get all questions
        questions = QuestionPairing.questions_for_summary(false)
        
        disability_id = nil
              
        if evaluations.present? && questions.present?
          Rails.logger.debug "************* total evaluations found: #{evaluations.length}; total questions found = #{questions.length}"

          exists_question_ids = questions.select{|x| x.is_exists == true}.map{|x| x.id}
          req_accessibility_question_ids = questions.select{|x| x.required_for_accessibility == true}.map{|x| x.id}
          category_ids = questions.map{|x| x[:root_question_category_id]}.uniq
          question_ids = questions.map{|x| x[:question_id]}.uniq

          # get all existing summaries on record
          existing_summaries = PlaceSummary.not_certified(place_id)
          
          ##############################
          # compute and save overall summary
          ##############################
          Rails.logger.debug "************* computing overall summary"
          # - overall
          save_summary(place_id, 
                        existing_summaries, 
                        summarize_answers(evaluations, exists_question_ids, req_accessibility_question_ids, false), 
                        SAVE_TYPES['summary_overall'], SUMMARY_TYPES['overall'], DATA_TYPES['overall'])

          # - category
          save_category_summary(place_id, 
                                existing_summaries, 
                                summarize_category_answers(evaluations, questions, category_ids, exists_question_ids, req_accessibility_question_ids, false), 
                                category_ids, 
                                SAVE_TYPES['summary_category'], SUMMARY_TYPES['overall'], DATA_TYPES['category'])

          # - question
          save_question_summary(place_id, 
                                existing_summaries, 
                                summarize_question_answers(evaluations, questions, question_ids, exists_question_ids, req_accessibility_question_ids, false), 
                                question_ids, 
                                SAVE_TYPES['summary_question'], SUMMARY_TYPES['overall'], DATA_TYPES['question'])

          ##############################
          # if place_eval_id provided, get disability for that id
          # else get all disability ids in the evaluations
          ##############################
          disability_ids = nil
          if place_evaluation_id.present?
            disability_ids = evaluations.select{|x| x.id == place_evaluation_id}.map{|x| x.disability_id}.uniq
          else
            disability_ids = evaluations.map{|x| x.disability_id}.uniq
          end

          if disability_ids.present?
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
                filtered_question_ids = filtered_questions.map{|x| x[:question_id]}.uniq

                ##############################
                # compute summary for disability 
                ##############################
                Rails.logger.debug "************* computing disability summary"
                # - overall
                save_summary(place_id, 
                              existing_summaries, 
                              summarize_answers(filtered_evaluations, filtered_exists_question_ids, filtered_req_accessibility_question_ids, false), 
                              SAVE_TYPES['disability_overall'], SUMMARY_TYPES['disability'], DATA_TYPES['overall'], 
                              {'disability_id' => disability_id, 'summary_type_identifier' => disability_id})

                # - category
                save_category_summary(place_id, 
                                      existing_summaries, 
                                      summarize_category_answers(filtered_evaluations, filtered_questions, filtered_category_ids, filtered_exists_question_ids, filtered_req_accessibility_question_ids, false), 
                                      category_ids, 
                                      SAVE_TYPES['disability_category'], SUMMARY_TYPES['disability'], DATA_TYPES['category'], 
                                      {'disability_id' => disability_id, 'summary_type_identifier' => disability_id})

                # - question
                save_question_summary(place_id, 
                                      existing_summaries, 
                                      summarize_question_answers(filtered_evaluations, filtered_questions, filtered_question_ids, filtered_exists_question_ids, filtered_req_accessibility_question_ids, false), 
                                      question_ids, 
                                      SAVE_TYPES['disability_question'], SUMMARY_TYPES['disability'], DATA_TYPES['question'], 
                                      {'disability_id' => disability_id, 'summary_type_identifier' => disability_id})


                ##############################
                # if place_eval_id provided, compute summary for just that evalaution
                # else compute summary for every evaluation in this disability
                ##############################
                place_evaluation_ids = nil
                if place_evaluation_id.present?
                  place_evaluation_ids = [place_evaluation_id]
                else
                  place_evaluation_ids = filtered_evaluations.map{|x| x.id}.uniq
                end

                if place_evaluation_ids.present?
                  place_evaluation_ids.each do |place_eval_id|
                    Rails.logger.debug "************* computing instance summary for place eval #{place_eval_id}"
                    record_evaluations = filtered_evaluations.select{|x| x.id == place_eval_id}
                    if record_evaluations.present?
                      # - overall
                      save_summary(place_id, 
                                    existing_summaries, 
                                    summarize_answers(record_evaluations, filtered_exists_question_ids, filtered_req_accessibility_question_ids, false), 
                                    SAVE_TYPES['instance_overall'], SUMMARY_TYPES['instance'], DATA_TYPES['overall'], 
                                    {'disability_id' => disability_id, 'summary_type_identifier' => place_eval_id})

                      # - category
                      save_category_summary(place_id, 
                                            existing_summaries, 
                                            summarize_category_answers(record_evaluations, filtered_questions, filtered_category_ids, filtered_exists_question_ids, filtered_req_accessibility_question_ids, false), 
                                            category_ids, 
                                            SAVE_TYPES['instance_category'], SUMMARY_TYPES['instance'], DATA_TYPES['category'], 
                                            {'disability_id' => disability_id, 'summary_type_identifier' => place_eval_id})

                      # - question
                      save_question_summary(place_id, 
                                            existing_summaries, 
                                            summarize_question_answers(record_evaluations, filtered_questions, filtered_question_ids, filtered_exists_question_ids, filtered_req_accessibility_question_ids, false), 
                                            question_ids, 
                                            SAVE_TYPES['instance_question'], SUMMARY_TYPES['instance'], DATA_TYPES['question'], 
                                            {'disability_id' => disability_id, 'summary_type_identifier' => place_eval_id})
                    end
                  end
                end
              end          
            end
          end
        end
      end    
    end
    Rails.logger.debug "*****************************************"
    Rails.logger.debug "************* update_summaries: end"
    Rails.logger.debug "*****************************************"
  end


  # for the given place id, update the summary data for certified evaluations
  # place_id: id of place to summarize evaluations for
  # place_evaluation_id: id of evaluation to focus summary's on
  # - if place_evaluation_id not provided, then compute instance summary for every certified evaluation
  def self.update_certified_summaries(place_id, place_evaluation_id=nil)
    Rails.logger.debug "*****************************************"
    Rails.logger.debug "************* update_certified_summaries: start"
    Rails.logger.debug "*****************************************"
    if place_id.present?
      PlaceSummary.transaction do

        # get all evaluations for this place
        evaluations = PlaceEvaluation.with_answers_for_summary(place_id, is_certified: true, place_evaluation_id: place_evaluation_id)

        # get all questions
        questions = QuestionPairing.questions_for_summary(true)
        
        disability_id = nil
              
        if evaluations.present? && questions.present?
          Rails.logger.debug "************* total evaluations found: #{evaluations.length}; total questions found = #{questions.length}"
          
          exists_question_ids = questions.select{|x| x.is_exists == true}.map{|x| x.id}
          req_accessibility_question_ids = questions.select{|x| x.required_for_accessibility == true}.map{|x| x.id}
          category_ids = questions.map{|x| x[:root_question_category_id]}.uniq

          # get all existing summaries on record
          existing_summaries = PlaceSummary.certified(place_id)


          disability_ids = nil
          if place_evaluation_id.present?
            disability_ids = evaluations.select{|x| x.id == place_evaluation_id}.map{|x| x.disability_id}.uniq
          else
            disability_ids = evaluations.map{|x| x.disability_id}.uniq
          end

          if disability_ids.present?
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
                # if place_eval_id provided, compute summary for just that evalaution
                # else compute summary for every evaluation in this disability
                ##############################
                place_evaluation_ids = nil
                if place_evaluation_id.present?
                  place_evaluation_ids = [place_evaluation_id]
                else
                  place_evaluation_ids = filtered_evaluations.map{|x| x.id}.uniq.sort{|x,y| x[:id] <=> y[:id]}
                end

                if place_evaluation_ids.present?
                  place_evaluation_ids.each do |place_eval_id|
                    ##############################
                    # compute summary for instance 
                    ##############################
                    Rails.logger.debug "************* computing instance summary for place eval #{place_eval_id}"
                    record_evaluations = filtered_evaluations.select{|x| x.id == place_eval_id}
                    if record_evaluations.present?
                      # - overall
                      save_summary(place_id, 
                                    existing_summaries, 
                                    summarize_answers(record_evaluations, filtered_exists_question_ids, filtered_req_accessibility_question_ids, true), 
                                    SAVE_TYPES['instance_overall'], SUMMARY_TYPES['instance'], DATA_TYPES['overall'], 
                                    {'disability_id' => disability_id, 'summary_type_identifier' => place_eval_id, 'is_certified' => true})
                      # - category
                      save_category_summary(place_id, 
                                            existing_summaries, 
                                            summarize_category_answers(record_evaluations, filtered_questions, filtered_category_ids, filtered_exists_question_ids, filtered_req_accessibility_question_ids, true), 
                                            category_ids, 
                                            SAVE_TYPES['instance_category'], SUMMARY_TYPES['instance'], DATA_TYPES['category'], 
                                            {'disability_id' => disability_id, 'summary_type_identifier' => place_eval_id, 'is_certified' => true})
                    end
                  end
                end

                ##############################
                # save summary for disability
                # - just use the latest evaluation in this disability
                ##############################
                Rails.logger.debug "************* creating disability summary"
                latest_id = filtered_evaluations.map{|x| x.id}.max
                Rails.logger.debug "************* computing disability summary using place eval #{latest_id}"
                record_evaluations = filtered_evaluations.select{|x| x.id == latest_id}
                if record_evaluations.present?
                  # - overall
                  save_summary(place_id, 
                                existing_summaries, 
                                summarize_answers(record_evaluations, filtered_exists_question_ids, filtered_req_accessibility_question_ids, true), 
                                SAVE_TYPES['disability_overall'], SUMMARY_TYPES['disability'], DATA_TYPES['overall'], 
                                {'disability_id' => disability_id, 'summary_type_identifier' => disability_id, 'is_certified' => true})

                  # - category
                  save_category_summary(place_id, 
                                        existing_summaries, 
                                        summarize_category_answers(record_evaluations, filtered_questions, filtered_category_ids, filtered_exists_question_ids, filtered_req_accessibility_question_ids, true), 
                                        category_ids, 
                                        SAVE_TYPES['disability_category'], SUMMARY_TYPES['disability'], DATA_TYPES['category'], 
                                        {'disability_id' => disability_id, 'summary_type_identifier' => disability_id, 'is_certified' => true})
                end                  
              end
            end
            ##############################
            # save summary for overall
            # - just use the latest evaluation for each disability
            ##############################
            filtered_evaluations = []
            evaluations.map{|x| x.disability_id}.uniq.each do |disability_id|
              latest_id = evaluations.select{|x| x.disability_id == disability_id}.map{|x| x.id}.max
              filtered_evaluations << evaluations.select{|x| x.disability_id == disability_id && x.id == latest_id} if latest_id.present?
            end
            if filtered_evaluations.present?
              filtered_evaluations.flatten!              

              Rails.logger.debug "************* computing overall summary using #{filtered_evaluations.map{|x| x.id}.uniq.length} evaluations"
              save_summary(place_id, 
                            existing_summaries, 
                            summarize_answers(filtered_evaluations, exists_question_ids, req_accessibility_question_ids, true), 
                            SAVE_TYPES['summary_overall'], SUMMARY_TYPES['overall'], DATA_TYPES['overall'], {'is_certified' => true})
              save_category_summary(place_id, 
                                    existing_summaries, 
                                    summarize_category_answers(filtered_evaluations, questions, category_ids, exists_question_ids, req_accessibility_question_ids, true), 
                                    category_ids, 
                                    SAVE_TYPES['summary_category'], SUMMARY_TYPES['overall'], DATA_TYPES['category'], {'is_certified' => true})
              
            end
            
            
          end  
        end
      end
    end
    Rails.logger.debug "*****************************************"
    Rails.logger.debug "************* update_certified_summaries: end"
    Rails.logger.debug "*****************************************"
  end

private

  # format summary records into a hash format
  # return: {
  #  'overall' => {overall => {score, special_flag, num_evaluations, num_answers}, cat_id1 => {score, special_flag, num_evaluations, num_answers}, cat_id2, etc},
  #  'evaluations' => [{id, overall => {score, special_flag, num_evaluations, num_answers}, cat_id1 => {score, special_flag, num_evaluations, num_answers}, cat_id2, etc},etc]  
  # }
  def self.format_summary_hash(summaries)
    h = Hash.new
    
    if summaries.present?
      # get the overall summary 
      overall = summaries.select{|x| x.data_type == DATA_TYPES['overall']}
      h['overall'] = overall.present? ? overall.first.to_summary_hash : nil
      
      # get the category summaries
      categories = summaries.select{|x| x.data_type == DATA_TYPES['category']}
      if categories.present?
        h['categories'] = {}
        categories.each do |category|
          h['categories'][category.data_type_identifier.to_s] = category.to_summary_hash
        end
      end

      # get the question summaries
      questions = summaries.select{|x| x.data_type == DATA_TYPES['question']}
      if questions.present?
        h['questions'] = {}
        questions.each do |question|
          h['questions'][question.data_type_identifier.to_s] = question.to_summary_hash
        end
      end
    end
    
    return h
  end




  # records: array of place_evaluation_answers
  # exists_questions_ids: array of ids to questions that have exists flag
  # req_accessibility_question_ids: array of ids to questions that have required for accessibility flag
  # is_certified: boolean that indicates if the evaluations are public or certified
  # returns: {score, special_flag, num_answers, num_evaluations}
  # - score = overall average of records passed in unless a special case was found
  # - special_flag = one of SUMMARY_ANSWERS values or nil; will be nil if score has value
  # - num_answers = number of answers that exist
  # - num_evaluations = number of evaluations that exist
  # - percentage = converts score into a percent
  # - num_yes = number of answers that were 'yes', only populated for pulic evals
  # - num_no = number of answers that were 'no', only populated for pulic evals
  def self.summarize_answers(records, exists_question_ids, req_accessibility_question_ids, is_certified=true)
    h = {'score' => nil, 'special_flag' => nil, 'num_answers' => nil, 'num_evaluations' => nil, 'percentage' => nil, 'num_yes' => nil, 'num_no' => nil}
    
    if records.present?
      h['num_evaluations'] = records.map{|x| x.id}.uniq.length
      h['num_answers'] = records.select{|x| x[:answer] > PlaceEvaluation::ANSWERS['no_answer']}.length
      h['num_yes'] = records.select{|x| x[:answer] == PlaceEvaluation::ANSWERS['yes']}.length
      h['num_no'] = records.select{|x| x[:answer] == PlaceEvaluation::ANSWERS['no']}.length

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
=begin
          if is_certified
            h['percentage'] = 100*((h['score'] - PlaceEvaluation::ANSWERS['needs'])/(PlaceEvaluation::ANSWERS['has_good'].to_f - PlaceEvaluation::ANSWERS['needs']))
          else
            h['percentage'] = 100*((h['score'] - PlaceEvaluation::ANSWERS['no']))
          end
=end        
          h['percentage'] = 100*((h['score'] - PlaceEvaluation::ANSWERS['no']))
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
  # is_certified: boolean that indicates if the evaluations are public or certified
  # returns: {category_id => {summary answers}, category_id => {summary answers}}
  # - category_id = id of question category
  # - summary answers = hash of summary answers for the question category (see summarize_answers for hash that is returned)
  def self.summarize_category_answers(records, questions, category_ids, exists_question_ids, req_accessibility_question_ids, is_certified=true)
    answers = Hash.new
    
    if category_ids.present?
      category_ids.each do |category_id|
        question_pairing_ids = questions.select{|x| x.root_question_category_id == category_id}.map{|x| x.id}
  
        if question_pairing_ids.present?
          category_records = records.select{|x| question_pairing_ids.index(x[:question_pairing_id]).present? }
          if category_records.present?
              answers[category_id.to_s] = summarize_answers(category_records, exists_question_ids, req_accessibility_question_ids, is_certified)
          end
        end
      end    
    end
    
    return answers
  end
    

  # records: array of place_evaluation_answers
  # questions: array of questions
  # question_ids: array of unique question ids
  # exists_questions_ids: array of ids to questions that have exists flag
  # req_accessibility_question_ids: array of ids to questions that have required for accessibility flag
  # is_certified: boolean that indicates if the evaluations are public or certified
  # returns: {question_id => {summary answers}, question_id => {summary answers}}
  # - question_id = id of question category
  # - summary answers = hash of summary answers for the question (see summarize_answers for hash that is returned)
  def self.summarize_question_answers(records, questions, question_ids, exists_question_ids, req_accessibility_question_ids, is_certified=true)
    answers = Hash.new
    if question_ids.present?
      question_ids.each do |question_id|
        question_pairing_ids = questions.select{|x| x.question_id == question_id}.map{|x| x.id}
 
        if question_pairing_ids.present?
          question_records = records.select{|x| question_pairing_ids.index(x[:question_pairing_id]).present? }
          if question_records.present?
              answers[question_id.to_s] = summarize_answers(question_records, exists_question_ids, req_accessibility_question_ids, is_certified)
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
  # options:
  # - is_certified: whether this summary is for a certified evaluation
  # - summary_type_identifier: id of summary type record
  # - data_type_identifier: id of data type record
  # - disability_id: id of disability summary is for
  def self.save_summary(place_id, existing_summaries, summaries, type, summary_type, data_type, options={})
    summary = nil
    options['summary_type_identifier'] = nil if !options.has_key?('summary_type_identifier')
    options['data_type_identifier'] = nil if !options.has_key?('data_type_identifier')
    options['disability_id'] = nil if !options.has_key?('disability_id')
    options['is_certified'] = false if !options.has_key?('is_certified')
  
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
      
        when SAVE_TYPES['summary_overall']
          index = existing_summaries.index{|x| x.summary_type == summary_type && x.data_type == data_type}
          answers = summaries

        when SAVE_TYPES['summary_category'], SAVE_TYPES['summary_question']
          if options['data_type_identifier'].present?
            index = existing_summaries.index{|x| x.summary_type == summary_type && 
                                                      x.data_type == data_type && 
                                                      x.data_type_identifier == options['data_type_identifier']}
            answers = summaries[options['data_type_identifier'].to_s] if summaries.has_key?(options['data_type_identifier'].to_s)
          end

        when SAVE_TYPES['disability_overall']
          if options['disability_id'].present?
            index = existing_summaries.index{|x| x.summary_type == summary_type && 
                                                      x.summary_type_identifier == options['summary_type_identifier'] && 
                                                      x.data_type == data_type}
            answers = summaries
          end

        when SAVE_TYPES['disability_category'], SAVE_TYPES['disability_question']
          if options['disability_id'].present? && options['data_type_identifier'].present?
            index = existing_summaries.index{|x| x.summary_type == summary_type && 
                                                      x.summary_type_identifier == options['summary_type_identifier'] && 
                                                      x.data_type == data_type && 
                                                      x.data_type_identifier == options['data_type_identifier']}
            answers = summaries[options['data_type_identifier'].to_s] if summaries.has_key?(options['data_type_identifier'].to_s)
          end

        when SAVE_TYPES['instance_overall']
          if options['disability_id'].present?
            index = existing_summaries.index{|x| x.summary_type == summary_type && 
                                                      x.summary_type_identifier == options['summary_type_identifier'] && 
                                                      x.data_type == data_type}
            answers = summaries
          end

        when SAVE_TYPES['instance_category'], SAVE_TYPES['instance_question']
          if options['disability_id'].present? && options['data_type_identifier'].present?
            index = existing_summaries.index{|x| x.summary_type == summary_type && 
                                                      x.summary_type_identifier == options['summary_type_identifier'] && 
                                                      x.data_type == data_type && 
                                                      x.data_type_identifier == options['data_type_identifier']}
            answers = summaries[options['data_type_identifier'].to_s] if summaries.has_key?(options['data_type_identifier'].to_s)
          end        
      end

      Rails.logger.debug "************* - index = #{index}; answers = #{answers}"
  
      if answers.present?
        if index.blank? 
          # create new record
          # record does not exist, so create it
          summary = PlaceSummary.new
          summary.place_id = place_id
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
    Rails.logger.debug "*********************************"
    Rails.logger.debug "************* save_summary end"
    Rails.logger.debug "*********************************"
    return summary
  end
  
  # save the summary data for each category
  def self.save_category_summary(place_id, existing_summaries, summaries, category_ids, type, summary_type, data_type, options={})
    summary = []
    if category_ids.present?
      category_ids.each do |category_id|
        options['data_type_identifier'] = category_id
        summary << save_summary(place_id, existing_summaries, summaries, type, summary_type, data_type, options)      
      end
    end
    return summary
  end  

  # save the summary data for each question
  def self.save_question_summary(place_id, existing_summaries, summaries, question_ids, type, summary_type, data_type, options={})
    summary = []
Rails.logger.debug "************************ #{question_ids}"
    if question_ids.present?
      question_ids.each do |question_id|
        options['data_type_identifier'] = question_id
        summary << save_summary(place_id, existing_summaries, summaries, type, summary_type, data_type, options)      
      end
    end
    return summary
  end  
end
