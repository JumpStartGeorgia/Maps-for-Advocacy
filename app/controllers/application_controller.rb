class ApplicationController < ActionController::Base
	require 'will_paginate/array'
  protect_from_forgery

	before_filter :set_locale
	before_filter :is_browser_supported?
	before_filter :initialize_global_variables
	before_filter :initialize_gon
	after_filter :store_location

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

  def initialize_global_variables
    @lat = 41.69337
    @lon = 44.80149
    @district_id = 1

    if user_signed_in? && current_user.lat.present? && current_user.lon.present?
      @lat = current_user.lat
      @lon = current_user.lon
      @district_id = current_user.district_id
    end
  end

	def initialize_gon
		gon.set = true
		gon.highlight_first_form_field = false

		gon.tile_url = "http://{s}.tile.openstreetmap.org/{z}/{x}/{y}.png"
    gon.map_id = 'map'
    gon.zoom = 16
    gon.max_zoom = 18
    gon.lat = @lat
    gon.lon = @lon

    gon.zoom_front_page = 7
    gon.lat_front_page = @lat
    gon.lon_front_page = @lon
	end

	# after user logs in go back to the last page or go to root page
	def after_sign_in_path_for(resource)
		request.env['omniauth.origin'] || session[:previous_urls].last || root_path(:locale => I18n.locale)
	end

  def valid_role?(role)
    redirect_to root_path, :notice => t('app.msgs.not_authorized') if !current_user || !current_user.role?(role)
  end

	# store the current path so after login, can go back
	def store_location
		session[:previous_urls] ||= []
		# only record path if page is not for users (sign in, sign up, etc) and not for reporting problems
		if session[:previous_urls].first != request.fullpath && 
        params[:format] != 'js' && params[:format] != 'json' && 
        request.fullpath.index("/users/").nil?

			session[:previous_urls].unshift request.fullpath
		end
		session[:previous_urls].pop if session[:previous_urls].count > 1
	end



=begin
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
=end

  # add in required content for translations if none provided
  # - if default locale does not have translations, use first trans that does as default
  def add_missing_translation_content(ary_trans)
    if ary_trans.present?
      default_trans = ary_trans.select{|x| x.locale == I18n.default_locale.to_s}.first
  
      if default_trans.blank? || !default_trans.required_data_provided?
        # default locale does not have data so get first trans that does have data
        ary_trans.each do |trans|
          if trans.required_data_provided?
            default_trans = trans
            break
          end
        end
      end

      if default_trans.present? && default_trans.required_data_provided?
        ary_trans.each do |trans|
          if trans.locale != default_trans.locale && !trans.required_data_provided?
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
