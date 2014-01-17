module PlacesHelper

  # hash = {score, special_flag}
  def format_summary_result(hash)
    x = ''
    if hash.class == Hash
      if hash.has_key?('score') && hash['score'].present?
        percent = 100*hash['score']/PlaceEvaluation::ANSWERS['has_good'].to_f
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
        x << "</span>"
      elsif hash.has_key?('special_flag') && hash['special_flag'].present?
        key = PlaceEvaluation.summary_answer_key_name(hash['special_flag'])
        x << "<span class='summary_result_text #{key}'>"
        x << I18n.t("app.common.summary_answers.#{key}")
        x << "</span>"
      end
    end
    return x.html_safe
  end

end
