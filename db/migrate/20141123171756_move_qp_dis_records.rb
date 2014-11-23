class MoveQpDisRecords < ActiveRecord::Migration
  def up
    QuestionPairingDisability.transaction do
      # get records from disabilities_question_pairings to move QPD
      connection = ActiveRecord::Base.connection
      records = ActiveRecord::Base.connection.execute("select question_pairing_id, disability_id from disabilities_question_pairings;")

      if records.present?
        puts "found #{records.to_a.length} records to move"

        # now if any have help text, get those too
        qps = QuestionPairing.includes(:question_pairing_translations)
              .where(['question_pairings.id in (?) and length(question_pairing_translations.help_text) > 0', records.map{|x| x[0]}])

        puts "found #{qps.length} records that already have help text"

        # now add records
        records.each do |record|
          puts "- creating qp #{record[0]}; dis #{record[1]}"
          qpd = QuestionPairingDisability.new(:question_pairing_id => record[0], :disability_id => record[1])

          match = qps.select{|x| x.id == record[0]}.first
          if match.present?
            puts "-- adding translations"
            I18n.available_locales.each do |locale|
              # see if help text existed for this locale
              trans = match.question_pairing_translations.select{|x| x.locale == locale.to_s}.first
              if trans.present?
                qpd.question_pairing_disability_translations.build(:locale => locale, :content => trans.help_text) 
              end
            end

            # make sure help text exists for each translation
            default_trans = qpd.question_pairing_disability_translations.select{|x| x.locale == I18n.default_locale.to_s}.first
        
            if default_trans.blank? || !default_trans.required_data_provided?
              # default locale does not have data so get first trans that does have data
              qpd.question_pairing_disability_translations.each do |trans|
                if trans.required_data_provided?
                  default_trans = trans
                  break
                end
              end
            end

            if default_trans.present? && default_trans.required_data_provided?
              qpd.question_pairing_disability_translations.each do |trans|
                if trans.locale != default_trans.locale && !trans.required_data_provided?
                  # add required content from default locale trans
                  trans.add_required_data(default_trans)
                end
              end
            end

          end

          qpd.save

        end
      end

    end
  end

  def down
    QuestionPairingDisability.delete_all
    QuestionPairingDisabilityTranslation.delete_all
  end
end
