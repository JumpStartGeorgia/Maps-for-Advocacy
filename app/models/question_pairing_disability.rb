class QuestionPairingDisability < ActiveRecord::Base
  translates :content

  belongs_to :question_pairing
  belongs_to :disability

  has_many :question_pairing_disability_translations, :dependent => :destroy

  accepts_nested_attributes_for :question_pairing_disability_translations
  attr_accessible :question_pairing_id, :disability_id, :has_content, :question_pairing_disability_translations_attributes
  
  validates :question_pairing_id, :disability_id, :presence => true


  before_save :set_has_content

  # if the translation object exists and has content, set to true
  def set_has_content
    self.has_content = self.question_pairing_disability_translations.index{|x| x.content.present?}.present?
    return true
  end

  # get all records including ties to question category, question and disability tables
  # - if no options are provided, gets all questions pairing disablity records
  # options:
  # - question_pairing_id - gets records that have this id
  # - disability_ids - array of disability_ids to get records for
  # - search - phrase to search for
  # - sort_col - col to sort by
  # - sort_dir - direction to sort by
  # - limit - number of records to get
  # - offset - offset for pagination
  # - is_certified - boolean flag indicating to show public or certified records
  # - type - what disability type
  # - category - what category records have to belong to
  def self.with_names(options={})
    id = options[:id].present? ? options[:id] : nil
    question_pairing_id = options[:question_pairing_id].present? ? options[:question_pairing_id] : nil
    disability_ids = options[:disability_ids].present? ? options[:disability_ids] : nil
    search = options[:search].present? ? options[:search] : nil
    sort_col = options[:sort_col].present? ? options[:sort_col] : nil
    sort_dir = options[:sort_dir].present? ? options[:sort_dir] : nil
    limit = options[:limit].present? ? options[:limit] : nil
    offset = options[:offset].present? ? options[:offset] : nil
    is_certified = options[:is_certified].present? ? options[:is_certified].to_s.to_bool : nil
    type = options[:type].present? ? options[:type] : nil
    category = options[:category].present? ? options[:category] : nil
    paginate = !options[:paginate].nil? ? options[:paginate].to_s.to_bool : true

    sql = "SELECT qpd.id, qpd.question_pairing_id, qpd.disability_id, qpd.has_content, "
    sql << "if (qc_child.category_type = :common or qc_child.category_type = :custom, 1, 0) as is_certified,"
    sql << "if (qc_child.ancestry is null, qct_child.name, qct_parent.name) as question_category_parent, "
    sql << "if (qc_child.ancestry is null, null, qct_child.name) as question_category_child, "
    sql << "qt.name as question, dt.name as disability_name "
    sql << "from question_pairing_disabilities as qpd "
    sql << "left join question_pairing_disability_translations as qpdt ON qpdt.question_pairing_disability_id = qpd.id and qpdt.locale = :locale "
    sql << "inner join disabilities as d ON d.id = qpd.disability_id "
    sql << "inner join disability_translations as dt ON dt.disability_id = d.id and dt.locale = :locale "
    sql << "inner join question_pairings as qp ON qp.id = qpd.question_pairing_id "
    sql << "inner join questions as q ON q.id = qp.question_id "
    sql << "inner join question_translations as qt ON qt.question_id = q.id  and qt.locale = :locale "
    sql << "inner join question_categories as qc_child ON qc_child.id = qp.question_category_id "
    sql << "inner join question_category_translations as qct_child ON qct_child.question_category_id = qc_child.id  and qct_child.locale = :locale "
    sql << "left join question_categories as qc_parent ON qc_parent.id = qc_child.ancestry "
    sql << "left join question_category_translations as qct_parent ON qct_parent.question_category_id = qc_parent.id and qct_parent.locale = :locale "
    if id.present?
      sql << "where qpd.id = :id "
      if disability_ids.present?
        sql << "and qpd.disability_id in (:disability_ids) "
      end
    elsif question_pairing_id.present?
      sql << "where qpd.question_pairing_id = :question_pairing_id "
      if disability_ids.present?
        sql << "and qpd.disability_id in (:disability_ids) "
      end
    elsif search.present? || is_certified.to_s.present? || type.present? || category.present?
      sql << "where "
      has_content = false

      if search.present?
        sql << "(qct_child.name like :search or qct_parent.name like :search || qt.name like :search || dt.name like :search ) "
        has_content = true
      end
      
      if is_certified.to_s.present?
        if has_content
          sql << "and "
        end
        if !is_certified
          sql << "!"
        end
        sql << "(qc_child.category_type = :common or qc_child.category_type = :custom) "
        has_content = true
      end

      if type.present? && type != "0"
        if has_content
          sql << "and "
        end
        sql << "qpd.disability_id = :type "
        has_content = true
      end

      if category.present? && category != '0'
        if has_content
          sql << "and "
        end
        sql << "(qc_child.id = :category || qc_parent.id = :category) "
      end
    end
    if question_pairing_id.blank?
      if sort_col.present?
        # have to add the sort cols/dirn here instead of in the list of args below 
        # so that the '' are not included around the text items and so the order by works
        sql << "order by #{sort_col} #{sort_dir} "
      else
        sql << "order by qc_parent.sort_order, qc_child.sort_order, qp.sort_order "
      end
    end

    records = nil
    if paginate

      records = paginate_by_sql([sql, :common => QuestionCategory::TYPES['common'], 
                  :custom => QuestionCategory::TYPES['custom'], :id => id,
                  :locale => I18n.locale, :question_pairing_id => question_pairing_id,
                  :disability_ids => disability_ids, :search => "%#{search}%",
                  :sort_col => sort_col, :sort_dir => sort_dir,
                  :type => type, :category => category],
                  :page => offset, :per_page => limit)
    else

      records = find_by_sql([sql, :common => QuestionCategory::TYPES['common'], 
                  :custom => QuestionCategory::TYPES['custom'], :id => id,
                  :locale => I18n.locale, :question_pairing_id => question_pairing_id,
                  :disability_ids => disability_ids, :search => search,
                  :sort_col => sort_col, :sort_dir => sort_dir,
                  :limit => limit, :offset => offset])
    end

    return id.present? ? records.first : records
  end

  # get count of all records including ties to question category, question and disability tables
  # - if no options are provided, gets all questions pairing disablity records
  # options:
  # - question_pairing_id - gets records that have this id
  # - disability_ids - array of disability_ids to get records for
  def self.with_names_count(options={})
    question_pairing_id = options[:question_pairing_id].present? ? options[:question_pairing_id] : nil
    disability_ids = options[:disability_ids].present? ? options[:disability_ids] : nil
    sql = "SELECT count(*) as count "
    sql << "from question_pairing_disabilities as qpd "
    sql << "left join question_pairing_disability_translations as qpdt ON qpdt.question_pairing_disability_id = qpd.id and qpdt.locale = :locale "
    sql << "inner join disabilities as d ON d.id = qpd.disability_id "
    sql << "inner join disability_translations as dt ON dt.disability_id = d.id and dt.locale = :locale "
    sql << "inner join question_pairings as qp ON qp.id = qpd.question_pairing_id "
    sql << "inner join questions as q ON q.id = qp.question_id "
    sql << "inner join question_translations as qt ON qt.question_id = q.id  and qt.locale = :locale "
    sql << "inner join question_categories as qc_child ON qc_child.id = qp.question_category_id "
    sql << "inner join question_category_translations as qct_child ON qct_child.question_category_id = qc_child.id  and qct_child.locale = :locale "
    sql << "left join question_categories as qc_parent ON qc_parent.id = qc_child.ancestry "
    sql << "left join question_category_translations as qct_parent ON qct_parent.question_category_id = qc_parent.id and qct_parent.locale = :locale "
    if question_pairing_id.present?
      sql << "where qpd.question_pairing_id = :question_pairing_id "
      if disability_ids.present?
        sql << "and qpd.disability_id in (:disability_ids) "
      end
    end

    x = find_by_sql([sql, :common => QuestionCategory::TYPES['common'], 
                :custom => QuestionCategory::TYPES['custom'],
                :locale => I18n.locale, :question_pairing_id => question_pairing_id,
                :disability_ids => disability_ids])

    return x.first['count']
  end

  # if quesiton category type - 1/2 -> certified
  # else public
  def is_certified?
    self[:is_certified].to_s.to_bool
  end

  def certified_text
    if self.is_certified?
      I18n.t('app.common.certified')
    else
      I18n.t('app.common.public')
    end
  end

  def question_category
    self[:question_category_parent]
  end

  def question_subcategory
    self[:question_category_child]
  end

  def question
    self[:question]
  end

  def disability_name
    self[:disability_name]
  end



  #######################################
  ## load all question categories, quetsions and pairings from the main spreadsheet
  #######################################
  def self.update_csv_upload()
    file_path = "#{Rails.root}/db/spreadsheets/help_text_images.csv"
    images_path = "#{Rails.root}/db/images/help_text"
    process_csv_upload(File.open(file_path, 'r'), images_path)
  end  
  
  #######################################
  ## load help text/images from csv file
  #######################################
  def self.process_csv_upload(file, img_folder_path)
    require 'image_processing'

    start = Time.now
    infile = file.read
    n, msg = 0, ""
    idx_unique_id = 0
    idx_types = 1
    idx_img_name = 2
    idx_text_en = 3
    idx_text_ka = 4

    original_locale = I18n.locale
    I18n.locale = :en

    QuestionPairingDisability.transaction do
    
      CSV.parse(infile) do |row|
        question = nil
        startRow = Time.now
        n += 1
        puts "@@@@@@@@@@@@@@@@@@ processing row #{n}"

        if n > 1
          unique_id = row[idx_unique_id].strip
          types = row[idx_types].strip.split(',')


          if !(unique_id.present? && types.present?)
            msg = "Row #{n}: Could not find Unique Question ID or Disability Type"
            raise ActiveRecord::Rollback
            return msg
          end

          puts "---- unique id = #{unique_id}"

          # for each type, find matching qpd record
          types.each do |type|
            puts "---- disability code = #{type}"
            qpd = QuestionPairingDisability.includes(:question_pairing_disability_translations, :question_pairing, :disability)
                    .where(['question_pairings.unique_id = ? and disabilities.code = ?', unique_id, type]).first

            if qpd.blank?
              msg = "Row #{n}: Could not find the Question Pairing Disability record that matches this Unique Question ID and Disability Type"
              raise ActiveRecord::Rollback
              return msg
            end

            puts "---- qpd id = #{qpd.id}"

            # get reference to trans objects
            trans_en = qpd.question_pairing_disability_translations.select{|x| x.locale == 'en'}.first
            trans_ka = qpd.question_pairing_disability_translations.select{|x| x.locale == 'ka'}.first
            trans_en.content = '' if trans_en.content.nil?
            trans_ka.content = '' if trans_ka.content.nil?

            # if text is present, add it
            if (row[idx_text_en].present? && row[idx_text_en].strip.present?) || 
               (row[idx_text_ka].present? && row[idx_text_ka].strip.present?)

              puts "---- found text, adding it"

              if (row[idx_text_en].present? && row[idx_text_en].strip.present?) &&
               (row[idx_text_ka].present? && row[idx_text_ka].strip.present?)
                trans_en.content << "<p>#{row[idx_text_en].strip}</p>"
                trans_ka.content << "<p>#{row[idx_text_ka].strip}</p>"

              elsif (row[idx_text_en].present? && row[idx_text_en].strip.present?) &&
               (row[idx_text_ka].blank? || row[idx_text_ka].strip.blank?)
                trans_en.content << "<p>#{row[idx_text_en].strip}</p>"
                trans_ka.content << "<p>#{row[idx_text_en].strip}</p>"

              elsif (row[idx_text_ka].present? && row[idx_text_ka].strip.present?) &&
               (row[idx_text_en].blank? || row[idx_text_en].strip.blank?)
                trans_en.content << "<p>#{row[idx_text_ka].strip}</p>"
                trans_ka.content << "<p>#{row[idx_text_ka].strip}</p>"
              end

              # if text has a url, convert it to a link
              URI::extract(trans_en.content).each do |url|
                if url.start_with?('http://', 'https://')
                  trans_en.content.gsub(url, "<a href='#{url}' target='_blank'>#{url}</a> ")
                end
              end
              URI::extract(trans_ka.content).each do |url|
                if url.start_with?('http://', 'https://')
                  trans_ka.content.gsub(url, "<a href='#{url}' target='_blank'>#{url}</a> ")
                end
              end
            end

            # if image is present, process it and add to text
            if row[idx_img_name].present?
              puts "---- found img, adding it"

              # see if image exists
              # image name does not include extension, so have to try both png and jpg
              img_name = row[idx_img_name].strip.dup
              path = "#{img_folder_path}/#{unique_id}"

              if File.exists?("#{path}/#{img_name}.png")
                img_name << ".png"
              elsif File.exists?("#{path}/#{img_name}.jpg")
                img_name << ".jpg"
              else
                msg = "Row #{n}: Could not find the image #{img_name} in #{path}"
                raise ActiveRecord::Rollback
                return msg
              end

              # save the image
              url, img_msg = ImageProcessing.save(File.open("#{path}/#{img_name}", 'r'), img_name, qpd.id)

              if url.blank?
                msg = "Row #{n}: Could not process the image #{img_name} in #{path}: #{img_msg}"
                raise ActiveRecord::Rollback
                return msg
              end

              # convert img name into a heading
              # - remove all but alpha from name
              help_text = "<p><strong>#{row[idx_img_name].gsub(/[^[:alpha:]\s]/, '').strip}</strong></p>"
              help_text << "<p><img src='#{url}' alt='#{row[idx_img_name].strip}' class='image' /></p>"

              trans_en.content << help_text
              trans_ka.content << help_text

            end

            if !qpd.save
              msg = "Row #{n}: Error while adding the help text: #{qpd.errors.full_messages.join(', ')}"
              raise ActiveRecord::Rollback
              return msg
            end
          end

          puts "******** time to process row: #{Time.now-startRow} seconds"
          puts "************************ total time so far : #{Time.now-start} seconds"
        end
      end  
  
    end

    # reset the locale
    I18n.locale = original_locale

    puts "****************** time to build help text from csv: #{Time.now-start} seconds for #{n} rows"

    return msg
  end

end
