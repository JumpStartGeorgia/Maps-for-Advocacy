module PlacesHelper

  # hash = {score, special_flag}
  def format_summary_result(hash, options={})
    options[:is_summary] = false if options[:is_summary].nil?
    options[:is_certified] = true if options[:is_certified].nil?
    x = ''
    if hash.class == Hash
      if hash.has_key?('score') && hash['score'].present?
        percent = nil
        if options[:is_certified]
          percent = 100*((hash['score'] - PlaceEvaluation::ANSWERS['needs'])/(PlaceEvaluation::ANSWERS['has_good'].to_f - PlaceEvaluation::ANSWERS['needs']))
        else
          percent = 100*((hash['score'] - PlaceEvaluation::ANSWERS['no']))
        end
        key = case percent
          when 0..25
            'bad'
          when 25..75
            'middle'
          else
            'good'
        end
        x << "<span class='summary_result_number #{key}'>"
        x << number_to_percentage(number_with_precision(percent))
        x << " ("
        if options[:is_summary] == true
          x << "<abbr title='Number of Evlauations'>E</abbr>="
          x << number_with_delimiter(hash['num_evaluations'])
          x << ", "
        end
        x << "<abbr title='Number of Answers'>A</abbr>="
        x << number_with_delimiter(hash['num_answers'])
        x << ")"
        x << "</span>"
      elsif hash.has_key?('special_flag') && hash['special_flag'].present?
        key = PlaceEvaluation.summary_answer_key_name(hash['special_flag'])
        x << "<span class='summary_result_text #{key}'>"
        x << I18n.t("app.common.summary_answers.#{key}")
        if hash['special_flag'] != PlaceEvaluation::SUMMARY_ANSWERS['no_answer']
          x << " ("
          if options[:is_summary] == true
            x << "<abbr title='Number of Evlauations'>E</abbr>="
            x << number_with_delimiter(hash['num_evaluations'])
            x << ", "
          end
          x << "<abbr title='Number of Answers'>A</abbr>="
          x << number_with_delimiter(hash['num_answers'])
          x << ")"
        end
        x << "</span>"
      end
    end
    return x.html_safe
  end

end
