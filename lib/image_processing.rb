# encoding: utf-8
module ImageProcessing

  def self.save(file_to_process, original_file_name, id)
    msg = nil
    img_url = nil
    if file_to_process.present? && (file_to_process.size/1024/1024) <= 5 
      file_name = transliterate_path(original_file_name)
      if ['.jpg','.png'].index(File.extname(file_name)).present?       

        path = "#{Rails.root}/public/system/help_text_images/#{id}"
        original_path = "#{path}/original"
        original_file = "#{original_path}/#{file_name}"
        medium_path = "#{path}/medium"
        url = "/system/help_text_images/#{id}/medium/#{file_name}"

        # make sure the path to the file exists
        FileUtils.mkpath(original_path)
        FileUtils.mkpath(medium_path)

        # save the original file
        File.open(original_file, 'wb') do |file|
          file.write(file_to_process.read)   
        end
        
        # create the versions
        if File.exists?(original_file)       
          Subexec.run "convert #{original_file} -resize '500x500>' #{medium_path}/#{file_name}"                
          img_url = url
        else
          msg = I18n.t('imageuploader.missing')
        end         
      else
        msg = I18n.t('imageuploader.invalid_type')
      end
    else 
      msg = I18n.t('imageuploader.size_limit')
    end

    return img_url, msg
  end

private

  def self.transliterate(str)
    # Based on permalink_fu by Rick Olsen      
    # Escape str by transliterating to UTF-8 with Iconv http://stackoverflow.com/questions/12947910/force-strings-to-utf-8-from-any-encoding
    #s = Iconv.iconv('ascii//ignore//translit', 'utf-8', str).to_s
    s = str.force_encoding("UTF-8")  
    # Downcase string
    s.downcase!
   
    # Remove apostrophes so isn't changes to isnt
    s.gsub!(/'/, '')
   
    # Replace any non-letter or non-number character with a space
    s.gsub!(/[^[[:alnum:]]]+/, ' ')
   
    # Remove spaces from beginning and end of string
    s.strip!
   
    # Replace groups of spaces with single hyphen
    s.gsub!(/\ +/, '-')
   
    return s
  end

  def self.transliterate_path( filename )
    extension = File.extname(filename).gsub(/^\.+/, '')  
    name = filename.gsub(/\.#{extension}$/, '')

    "#{transliterate(name)}.#{transliterate(extension)}"
  end

end