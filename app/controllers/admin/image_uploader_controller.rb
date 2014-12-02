class Admin::ImageUploaderController < ApplicationController
  require 'image_processing'
  before_filter :authenticate_user!
  before_filter do |controller_instance|
    controller_instance.send(:valid_role?, User::ROLES[:site_admin])
  end

  require 'fileutils'

  def create
    url, msg = ImageProcessing.save(params[:file], params[:file].original_filename, params[:id])

    if url.present?
      render json: { image: { url: "#{url}" } }, content_type: "text/html"          
    else
      render json: {error: {message: msg }}, content_type: "text/html"
    end

   #  uploaded_io = params[:file]    
   #  if params[:file].present? && (params[:file].size/1024/1024) <= 5 
   #    file_name = transliterate_path(uploaded_io.original_filename)
   #    if ['.jpg','.png'].index(File.extname(file_name)).present?       

   #      path = "public/system/help_text_images/#{params['id']}"
   #      original_path = "#{path}/original"
   #      original_file = "#{original_path}/#{file_name}"
   #      medium_path = "#{path}/medium"
   #      url = "/system/help_text_images/#{params['id']}/medium/#{file_name}"

   #      # make sure the path to the file exists
   #      FileUtils.mkpath(original_path)
   #      FileUtils.mkpath(medium_path)

   #      # save the original file
   #      File.open(original_file, 'wb') do |file|
   #        file.write(uploaded_io.read)   
   #      end
        
   #      # create the versions
   #      if File.exists?(original_file)       
   #          Subexec.run "convert #{original_file} -resize '500x500>' #{Rails.root.join(medium_path,file_name)}"                
   #          render json: { image: { url: "#{url}" } }, content_type: "text/html"          
   #      else
   #          render json: {error: {message: I18n.t('imageuploader.missing') }}, content_type: "text/html"
   #      end         

   #    else
   #      render json: {error: {message: I18n.t('imageuploader.invalid_type') }}, content_type: "text/html"
   #    end
   # else 
   #    render json: {error: {message: I18n.t('imageuploader.size_limit') }}, content_type: "text/html"
   # end
  end 


end