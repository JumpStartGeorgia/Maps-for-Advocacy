class RootController < ApplicationController

  def index
    @venue_categories = VenueCategory.names_with_count
    
    @places = Place.places_by_category(params[:venue_category_id])

    gon.show_frontpage_map = true
    @show_map = true
  
    # if places found, then save info to gon so can show markers/popups
    if @places.present?
      gon.markers = []
      
      @places.each do |place|
        marker = Hash.new
        marker['lat'] = place.lat
        marker['lon'] = place.lon
        marker['popup'] = "<h3>#{place[:place]}</h3><h4>#{place[:venue]}</h4><p>#{place[:address]}</p>#{view_context.link_to('view more', place_path(:id => place.id))}"
        gon.markers << marker
      end
    end
  
    respond_to do |format|
      format.html # index.html.erb
      format.json { render json: @places }
    end
  end

  def place
    @place = Place.find(params[:id])

    # get venue
    @venue = Venue.with_translations(I18n.locale).find_by_id(@place.venue_id)
	  # get list of questions
	  @question_categories = QuestionCategory.questions_for_venue(@venue.question_category_id)

    if @place.lat.present? && @place.lon.present?
      @show_map = true
      gon.show_place_map = true

      gon.lat = @place.lat
      gon.lon = @place.lon
    end    
  
    respond_to do |format|
      format.html # index.html.erb
      format.json { render json: @place }
    end
  end

end
