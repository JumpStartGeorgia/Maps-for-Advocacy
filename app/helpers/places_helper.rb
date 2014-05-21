module PlacesHelper

  # hash = {score, percentage, special_flag, num_answers, num_evaluations, num_yes, num_no}
  def format_summary_result(hash, options={})
    options[:is_summary] = false if options[:is_summary].nil?
    options[:is_certified] = true if options[:is_certified].nil?
    
=begin
    if options[:is_certified]
      return format_certified_summary_result(hash, options)
    else
      return format_public_summary_result(hash, options)
    end
=end    
    return format_public_summary_result(hash, options)
  end

private  
  def format_public_summary_result(hash, options)
    x = ''
    if hash.class == Hash
      if hash.has_key?('percentage') && hash['percentage'].present?
        x << "<div class='public_summary_container'>"
        x << "<div class='yes_votes' title='"
        if options[:is_summary] == true
          x << I18n.t('app.common.yes_votes', :votes => hash['num_yes'])
        else
          x << I18n.t('app.common.yes_vote')
        end
        x << "'>"
        if options[:is_summary] == true || options[:is_certified] == true
          x << hash['num_yes'].to_s
          x << "<i class='icon-white icon-thumbs-up'></i>"
        elsif hash['num_yes'] != 0
          x << "<i class='icon-white icon-thumbs-up'></i>"
        else 
          x << "&nbsp;"        
        end
        x << "</div>"
        x << "<div class='progress' title='"
        if options[:is_summary] == true
          x << I18n.t('app.common.yes_votes', :votes => hash['num_yes'])
          x << "&nbsp;&nbsp;|&nbsp;&nbsp;" 
          x << I18n.t('app.common.no_votes', :votes => hash['num_no'])
        elsif hash['num_yes'] != 0
          x << I18n.t('app.common.yes_vote')
        else
          x << I18n.t('app.common.no_vote')
        end
        x << "'><div class='bar bar-success' style='width: "
        sum = hash['num_yes'] + hash['num_no']
        x << (100*hash['num_yes']/sum.to_f).to_s
        x << "%;'></div><div class='bar bar-danger' style='width: "
        x << (100*hash['num_no']/sum.to_f).to_s
        x << "%;'></div></div>"
        x << "<div class='no_votes' title='"
        if options[:is_summary] == true
          x << I18n.t('app.common.no_votes', :votes => hash['num_no'])
        else
          x << I18n.t('app.common.no_vote')
        end
        x << "'>"
        if options[:is_summary] == true || options[:is_certified] == true
          x << "<i class='icon-white icon-thumbs-down'></i>"
          x << hash['num_no'].to_s
        elsif hash['num_no'] != 0
          x << "<i class='icon-white icon-thumbs-down'></i>"
        else
          x << "&nbsp;"        
        end
        x << "</div></div>"
      elsif hash.has_key?('special_flag') && hash['special_flag'].present?
        key = PlaceEvaluation.summary_answer_key_name(hash['special_flag'])
        x << "<div class='summary_result_text #{key} public_summary'>"
        x << I18n.t("app.common.summary_answers.#{key}")
        x << "</div>"
      end
    end
    return x.html_safe    
  end

  def format_certified_summary_result(hash, options)
    x = ''
    if hash.class == Hash
      if hash.has_key?('percentage') && hash['percentage'].present?
        key = case hash['percentage']
          when 0..25
            'bad'
          when 25..75
            'middle'
          else
            'good'
        end
        x << "<span class='summary_result_number #{key}'>"
        x << number_to_percentage(number_with_precision(hash['percentage']))
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
