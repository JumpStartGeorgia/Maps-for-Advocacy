# encoding: utf-8
module ResultsToCsv


  #############################
  ## write all results to csv files
  ## each place will gets its own folder
  ## and each evaluation for that place will then get
  ## its own csv file
  #############################
  def self.generate
    start = Time.now

    original_locale = I18n.locale
    I18n.locale = :en
    # make sure the parent directory exists
    path = "#{Rails.root}/db/results_to_csv/"
    FileUtils.mkdir_p(path)

    # delete all exisitng files first
    FileUtils.rm_r(Dir.glob("#{path}*"))    

    # get related content
    disabilities = Disability.is_active.sorted
    venues = Venue.with_translations(I18n.locale)
    categories = QuestionCategory.with_translations(I18n.locale)
    questions = Question.with_translations(I18n.locale)

    # get all places that have evaluations
    place_ids = PlaceEvaluation.select('place_id').map{|x| x.place_id}.uniq
    places = Place.with_translations(I18n.locale).where(:id => place_ids)

    file_count = 0

    if places.present?
      puts "there are #{places.length} places with evaluations"
      places.each_with_index do |place, place_index|
        puts "========================="

        # get the venue for this place
        venue = venues.select{|x| x.id == place.venue_id}.first

        puts "- place = #{place.id}; venue = #{venue.name}; name = #{place.name}; address = #{place.address}"
        # create folder for place with format: venue-id-place-address
        folder = "#{venue.name}||#{place.id}||#{place.name}||#{place.address}".gsub(/[\s]/, '_').gsub(/[^\d\w\|]/, '')
        puts "- folder = #{folder}"
        FileUtils.mkdir_p(path + folder)

        # get public and certified evaluations
        [true, false].each do |is_certified|
          type = is_certified == true ? 'certified' : 'public'
          puts "  ******  "
          puts "  -- #{type} evaluations"
          # get evaluations for this place 
          evaluations = PlaceEvaluation.includes(:place_evaluation_answers)
                            .where(:place_id => place.id, :is_certified => is_certified) 

          if evaluations.present?
            puts "- #{evaluations.length} #{type} evaluations"
            evaluations.each do |evaluation|
              content = []
              puts "  ------------  "
              disability = disabilities.select{|x| x.id == evaluation.disability_id}.first
              # csv file name format: public/certified - disablity - id
              filename = "#{type}||#{disability.name}||#{evaluation.id}.csv"
              puts "  - filename = #{filename}"

              # start file with place and eval info
              content << ["Place ID:", place.id]
              content << ["Place Name:", place.name]
              content << ["Place Address:", place.address]
              content << ["Venue: ", venue.name]
              content << ["User ID: ", evaluation.user_id]
              content << []
              content << ['Evaluation Type:', type]
              content << ['Disability Type:', disability.name]
              content << []
              content << []

              # write out evaluation answers as following: category, question, answer, ev1, ev2, ev3, ev angle
              content << ["Category", "Question", "Answer", "Evidence 1", "Evidence 2", "Evidence 3", "Evidence Angle"]
              category_id = nil
              category_name = nil
              evaluation.place_evaluation_answers.each do |answer|
                row = []
                
                pairing = answer.question_pairing

                # the category can repeat many times so no need to look it up for every question
                if pairing.question_category_id == category_id && category_name.present?
                  row << category_name
                else
                  category_id = pairing.question_category_id
                  category_name = categories.select{|x| x.id == pairing.question_category_id}.first.name
                  row << category_name
                end
                row << questions.select{|x| x.id == pairing.question_id}.first.name
                row << I18n.t("app.common.answers.#{PlaceEvaluation.answer_key_name(answer.answer)}")
                row << answer.evidence1
                row << answer.evidence2
                row << answer.evidence3
                row << answer.evidence_angle

                content << row
              end

              # write to csv
              CSV.open("#{path}#{folder}/#{filename}", 'w') do |csv|
                content.each do |row|
                  csv << row
                end
                file_count += 1
              end
            end
          end

        end

      end


    end

    # reset locale
    I18n.locale = original_locale

    puts "=================================="
    puts "Took #{Time.now-start} seconds to generate #{file_count} csv files"
    puts "=================================="

  end

end
