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

end
