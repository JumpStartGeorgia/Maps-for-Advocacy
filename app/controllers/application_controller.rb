class ApplicationController < ActionController::Base
	require 'will_paginate/array'
  protect_from_forgery

	before_filter :set_locale
	before_filter :is_browser_supported?
	before_filter :initialize_gon

	unless Rails.application.config.consider_all_requests_local
		rescue_from Exception,
		            :with => :render_error
		rescue_from ActiveRecord::RecordNotFound,
		            :with => :render_not_found
		rescue_from ActionController::RoutingError,
		            :with => :render_not_found
		rescue_from ActionController::UnknownController,
		            :with => :render_not_found
		rescue_from ActionController::UnknownAction,
		            :with => :render_not_found

    rescue_from CanCan::AccessDenied do |exception|
      redirect_to root_url, :alert => exception.message
    end
	end

	Browser = Struct.new(:browser, :version)
	SUPPORTED_BROWSERS = [
		Browser.new("Chrome", "15.0"),
		Browser.new("Safari", "4.0.2"),
		Browser.new("Firefox", "10.0.2"),
		Browser.new("Internet Explorer", "9.0"),
		Browser.new("Opera", "11.0")
	]

	def is_browser_supported?
		user_agent = UserAgent.parse(request.user_agent)
logger.debug "////////////////////////// BROWSER = #{user_agent}"
		if SUPPORTED_BROWSERS.any? { |browser| user_agent < browser }
			# browser not supported
#logger.debug "////////////////////////// BROWSER NOT SUPPORTED"
#			render "layouts/unsupported_browser", :layout => false
		end
	end


	def set_locale
    if params[:locale] and I18n.available_locales.include?(params[:locale].to_sym)
      I18n.locale = params[:locale]
    else
      I18n.locale = I18n.default_locale
    end
	end

  def default_url_options(options={})
    { :locale => I18n.locale }
  end

	def initialize_gon
		gon.set = true
		gon.highlight_first_form_field = true

		gon.tile_url = "http://{s}.tile.openstreetmap.org/{z}/{x}/{y}.png"
    gon.map_id = 'map'
    gon.zoom = 16
    gon.max_zoom = 18
    gon.lat = 41.69337
    gon.lon = 44.80149

    gon.zoom_front_page = 7
    gon.lat_front_page = 41.69337
    gon.lon_front_page = 44.80149
	end

	def after_sign_in_path_for(resource)
		root_path
	end

  def valid_role?(role)
    redirect_to root_path, :notice => t('app.msgs.not_authorized') if !current_user || !current_user.role?(role)
  end


  # add in required content for translations if none provided
  # - only do this if default locale trans record has data
  def add_missing_translation_content(ary_trans)
    if ary_trans.present?
      default_trans = ary_trans.select{|x| x.locale == I18n.default_locale.to_s}.first
      if default_trans.present? && default_trans.required_data_provided?
        ary_trans.each do |trans|
          if trans.locale != I18n.default_locale.to_s && !trans.required_data_provided?
            # add required content from default locale trans
            trans.add_required_data(default_trans)
          end
        end
      end
    end
  end



  #######################
	def render_not_found(exception)
		ExceptionNotifier::Notifier
		  .exception_notification(request.env, exception)
		  .deliver
		render :file => "#{Rails.root}/public/404.html", :status => 404
	end

	def render_error(exception)
		ExceptionNotifier::Notifier
		  .exception_notification(request.env, exception)
		  .deliver
		render :file => "#{Rails.root}/public/500.html", :status => 500
	end

end
