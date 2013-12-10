class SettingsController < ApplicationController
  before_filter :authenticate_user!

  def index
    @show_map = true
    gon.show_settings_map = true
    gon.address_search_path = address_search_places_path

    if params[:lat].present? && params[:lon].present?
      current_user.lat = params[:lat]
      current_user.lon = params[:lon]
      current_user.save

      gon.lat = params[:lat]
      gon.lon = params[:lon]
      
      flash[:success] = t('settings.location.success')
    end

    respond_to do |format|
      format.html 
      format.json { render json: current_user }
    end
  end
  
end
