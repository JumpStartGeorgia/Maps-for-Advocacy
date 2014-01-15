class RootController < ApplicationController

  def index
    options = {}
    options[:venue_category_id] = params[:venue_category_id] if params[:venue_category_id].present?
    options[:disability_id] = params[:eval_type_id] if params[:eval_type_id].present?
    params[:district_id] = @district_id if params[:district_id].blank?
    options[:district_id] = params[:district_id].present? && params[:district_id] != '0' ? params[:district_id] : nil
    options[:with_numbers_only] = true
    
    @venue_categories = VenueCategory.names_with_count(options)
    @disabilities = Disability.names_with_count(options)
    @districts = District.names_with_count(options)
    
    @places = Place.filtered(options)

    gon.show_frontpage_map = true
    gon.frontpage_filters = true
    @show_map = true
  
    # if places found, then save info to gon so can show markers/popups
    if @places.present?
      gon.markers = []
      
      @places.each do |place|
        marker = Hash.new
        marker['lat'] = place.lat
        marker['lon'] = place.lon
        marker['popup'] = create_popup_text(place)
        gon.markers << marker
      end
    end
  
    respond_to do |format|
      format.html # index.html.erb
      format.json { render json: @places }
    end
  end


  private
  
  def create_popup_text(place)
    popup = ''
    popup << "<h3>#{place[:place]}</h3>"
    popup << "<h4>#{place[:venue]}</h4>"
    popup << "<p>#{place[:address]}</p>"
    popup << "<p>"
    popup << view_context.link_to(t('app.common.view_place'), place_path(place.id), :title => t('app.common.view_place_title', :place => place[:place]), :class => 'view_more')
    popup << " "
    popup << view_context.link_to(t('app.common.add_evaluation'), evaluation_place_path(place), :title => t('app.common.add_evaluation_title', :place => place[:place]), :class => 'add_evaluation')
    popup << "</p>"
    
    # add image slide if exists
    gon.map_carousel_ids = []
    gon.map_carousel_id_text = "map_carousel_"
    if place.place_images.present?
      gon.map_carousel_ids << place.id
      
      popup << "<div id='map_carousel_#{place.id}' class='carousel slide'>"
        popup << '<div class="carousel-inner">'
          place.place_images.each_with_index do |img, index|
            popup << "<div class='#{'active' if index == 0} item'>"
              popup << view_context.image_tag(img.image.url(:thumb))
            popup << '</div>'
          end
        popup << '</div>'
        popup << "<a class='carousel-control left' href='#map_carousel_#{place.id}' data-slide='prev'>&lsaquo;</a>"
        popup << "<a class='carousel-control right' href='#map_carousel_#{place.id}' data-slide='next'>&rsaquo;</a>"
      popup << '</div>' 
    end
    
    
    return popup
  end
end
