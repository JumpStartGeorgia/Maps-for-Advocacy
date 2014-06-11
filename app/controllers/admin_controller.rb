class AdminController < ApplicationController
	require 'fileutils'
  before_filter :authenticate_user!
  before_filter do |controller_instance|
    controller_instance.send(:valid_role?, User::ROLES[:site_admin])
  end

  def index
    respond_to do |format|
      format.html # index.html.erb
    end
  end


  def why_monitor
    # get the text
    if File.exists?(@why_monitor_path)
      @why_monitor_text = JSON.parse(File.read(@why_monitor_path))
    else
      json = {}
      I18n.available_locales.each do |locale|
        json[locale.to_s] = ''
      end
			FileUtils.mkpath(File.dirname(@why_monitor_path))
      File.open(@why_monitor_path, 'w') { |f| f.write(json.to_json) }
      @why_monitor_text = json.to_json
    end
  
    if request.post?
      I18n.available_locales.each do |locale|
        @why_monitor_text[locale.to_s] = params["why_monitor_#{locale}"]
      end
      File.open(@why_monitor_path, 'w') { |f| f.write(@why_monitor_text.to_json) }

      flash[:notice] = I18n.t('app.msgs.success_updated', obj: I18n.t('admin.why_monitor.title'))
    end

  
    respond_to do |format|
      format.html
    end
  
  end
end
