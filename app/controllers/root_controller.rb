class RootController < ApplicationController

  def index
    options = {}
    options[:place_search] = params[:place_search].present? && params[:place_search].strip.present? ? prepare_search_text(params[:place_search]) : nil
    options[:address_search] = params[:address_search].present? && params[:address_search].strip.present? ? prepare_search_text(params[:address_search]) : nil
    options[:venue_category_id] = params[:venue_category_id] if params[:venue_category_id].present?
    options[:disability_id] = params[:eval_type_id] if params[:eval_type_id].present?
    params[:district_id] = @district_id if params[:district_id].blank?
    options[:district_id] = params[:district_id].present? && params[:district_id] != '0' ? params[:district_id] : nil
    options[:with_numbers_only] = true
    params[:places_with_evaluation] = params[:places_with_evaluation].present? ? params[:places_with_evaluation].to_bool : true
    options[:places_with_evaluation] = params[:places_with_evaluation]
    
    @venue_categories = VenueCategory.names_with_count(options)
    @disabilities = Disability.names_with_count(options)
    @districts = District.names_with_count(options)
    
    @places = Place.filtered(options)

    gon.show_frontpage_map = true
    gon.frontpage_filters = true
    @show_map = true
  
    # if places found, then save info to gon so can show markers/popups
    if @places.present?
      # get overall summaries for places
      @place_summaries = PlaceSummary.overall_summaries_for_places(@places.map{|x| x.id})
      
      gon.markers = []
      
      @places.each do |place|
        marker = Hash.new
        marker['id'] = place.id
        marker['lat'] = place.lat
        marker['lon'] = place.lon
        marker['popup'] = create_popup_text(place, @place_summaries)
        gon.markers << marker
      end
    end
    
    @page = Page.by_name('landing_page')
    @stats = {}
    @stats[:places_with_evals] = PlaceSummary.overall_places_with_evals
    @stats[:public_results] = PlaceSummary.overall_public_results
    @stats[:certified_results] = PlaceSummary.overall_certified_results

logger.debug "----------------- #{@stats}"
  
    respond_to do |format|
      format.html # index.html.erb
      format.json { render json: @places }
    end
  end

  
  def why_monitor
    @page = Page.by_name('why_monitor')
  
    if @page.present?
      respond_to do |format|
        format.html 
      end
    else
		  flash[:info] =  t('app.msgs.does_not_exist')
		  redirect_to root_path(:locale => I18n.locale)
		  return
	  end
  end

  def un_cprd
    @page = Page.by_name('un_cprd')
  
    if @page.present?
      respond_to do |format|
        format.html 
      end
    else
		  flash[:info] =  t('app.msgs.does_not_exist')
		  redirect_to root_path(:locale => I18n.locale)
		  return
	  end
  end

  def georgian_legislation
    @page = Page.by_name('georgian_legislation')
  
    if @page.present?
      respond_to do |format|
        format.html 
      end
    else
		  flash[:info] =  t('app.msgs.does_not_exist')
		  redirect_to root_path(:locale => I18n.locale)
		  return
	  end
  end

  def partners
    @page = Page.by_name('partners')
  
    if @page.present?
      respond_to do |format|
        format.html 
      end
    else
		  flash[:info] =  t('app.msgs.does_not_exist')
		  redirect_to root_path(:locale => I18n.locale)
		  return
	  end
  end


  private
  
  def create_popup_text(place, summaries=nil)
    popup = ''
    popup << "<h3>#{place[:place]}</h3>"
    popup << "<h4>#{place[:venue]}</h4>"
    popup << "<p>#{place[:address]}</p>"
    if summaries.present?
      # certified
      index = summaries.index{|x| x.place_id == place.id && x.is_certified == true}
      if index.present?
        popup << "<div>"
        popup << I18n.t('app.common.certified')
        popup << ': '
        popup << view_context.format_summary_result(summaries[index].to_summary_hash, is_summary: true)
        popup << "</div>"
      end
      # public
      index = summaries.index{|x| x.place_id == place.id && x.is_certified == false}
      if index.present?
        popup << "<div>"
        popup << I18n.t('app.common.public')
        popup << ': '
        popup << view_context.format_summary_result(summaries[index].to_summary_hash, is_summary: false)
        popup << "</div>"
      end
    end
    popup << "<p>"
    popup << view_context.link_to(t('app.common.view_place'), place_path(place.id), :title => t('app.common.view_place_title', :place => place[:place]), :class => 'view_more')
    popup << " "
    popup << view_context.link_to(t('app.common.add_evaluation'), evaluation_place_path(place), :title => t('app.common.add_evaluation_title', :place => place[:place]), :class => 'add_evaluation')
    popup << "</p>"
    
    # add image slide if exists
    gon.map_carousel_ids = []
    gon.map_carousel_id_text = "map_carousel_"
    place_images = PlaceImage.by_place(place.id).sorted
    if place_images.present?
      gon.map_carousel_ids << place.id
      
      popup << "<div id='map_carousel_#{place.id}' class='carousel slide'>"
        popup << '<div class="carousel-inner">'
          place_images.each_with_index do |img, index|
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
  
  
  def prepare_search_text(text)
    text.strip.latinize.to_ascii.downcase
  end
end
