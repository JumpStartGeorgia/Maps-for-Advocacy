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
      
      flash[:success] = t('settings.index.success')
    else params[:remove].present? && params[:remove] == 'true'
      current_user.lat = nil
      current_user.lon = nil
      current_user.save

      flash[:success] = t('settings.index.removed')
    end
    
    logger.debug "**************** #{gon.lat}"

    respond_to do |format|
      format.html 
      format.json { render json: current_user }
    end
  end
  
end
