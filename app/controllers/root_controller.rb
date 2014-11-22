class RootController < ApplicationController

  def index    
#    @venue_categories = VenueCategory.sorted

    @how_report = Page.by_name('how_report')

    @stats = {}
    @stats[:places_with_evals] = PlaceSummary.overall_places_with_evals
    @stats[:public_results] = PlaceSummary.overall_public_results
    @stats[:certified_results] = PlaceSummary.overall_certified_results

    gon.front_page = true
    gon.find_evaluations_path = find_places_path(:district_id => 0)

    respond_to do |format|
      format.html # index.html.erb
      format.json { render json: @page }
    end
  end

  
  def find_places
    options = {}
    options[:place_search] = params[:place_search].present? && params[:place_search].strip.present? ? prepare_search_text(params[:place_search]) : nil
    options[:address_search] = params[:address_search].present? && params[:address_search].strip.present? ? prepare_search_text(params[:address_search]) : nil
    options[:venue_category_id] = params[:venue_category_id] if params[:venue_category_id].present? && params[:venue_category_id] != '0'
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

    gon.show_find_evaluations_map = true
    gon.find_evaluations_filters = true
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
    
    respond_to do |format|
      format.html # index.html.erb
      format.json { render json: @places }
    end
  end


  def about
    @page = Page.by_name('about')
  
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

  def contact
    @page = Page.by_name('contact')
  
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

  def stats
    # eval results
    @eval_results_public = PlaceSummary.overall_public_results
    @eval_results_certified = PlaceSummary.overall_certified_results
    @eval_results_types = PlaceSummary.overall_results_by_type

    #submissions
    @user_all = PlaceEvaluation.stats_by_user
    @user_latest = PlaceEvaluation.stats_by_user(30)
    @org_all = PlaceEvaluation.stats_by_org
    @org_latest = PlaceEvaluation.stats_by_org(30)
    @cert = PlaceEvaluation.stats_by_cert
    @types = PlaceEvaluation.stats_by_type
    @images = PlaceEvaluation.stats_with_images

    respond_to do |format|
      format.html # index.html.erb
      format.json { render json: @training_videos }
    end
  end

  def video_guides
    @training_videos = TrainingVideo.sorted

    @watched_videos = TrainingVideoResult.watched_videos(current_user.id) if user_signed_in?

    respond_to do |format|
      format.html # index.html.erb
      format.json { render json: @training_videos }
    end
  end

  def video_guide
    @training_video = TrainingVideo.find(params[:id])

    gon.record_progress_path = record_video_guide_progress_path

    respond_to do |format|
      format.html # index.html.erb
      format.json { render json: @training_video }
    end
  end

  # as the user progresses through the training videos, record thier progress
  def record_training_video_progress
    respond_to do |format|
      format.js { 
        # make sure video exists
        if TrainingVideo.select('id').find_by_id(params[:id]).present?
          # if the user is not logged in, still record the survey progress
          user_id = user_signed_in? ? current_user.id : nil

          survey = TrainingVideoResult.find_by_id(params[:survey_id]) if params[:survey_id].present?

          if survey.blank?
            survey = TrainingVideoResult.new
            survey.user_id = user_id
            survey.training_video_id = params[:id]
            # get country from ip
            location = Geocoder.search(request.remote_ip)
            if location.present?
              survey.country = location.first.country
              survey.ip_address = request.remote_ip
            end
          end
          
          survey.pre_survey_answer = params[:pre_survey_answer].to_bool if params[:pre_survey_answer].present?
          survey.post_survey_answer = params[:post_survey_answer].to_bool if params[:post_survey_answer].present?
          survey.watched_video = params[:watched_video].to_bool if params[:watched_video].present?
          survey.save

          # if user is logged in and has watched the video, update their show_popup_training flag
          # so popup does not show when they do an evaluation
          if user_signed_in? && survey.watched_video? && current_user.show_popup_training?
            current_user.show_popup_training = false
            current_user.save
          end

          render json: {survey_id: survey.id}
          return
        end

        render nothing: true
      }
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

  def un_crpd
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

  def what_is_accessibility
    @page = Page.by_name('what_accessibility')
  
    @training_videos = TrainingVideo.sorted
    @watched_videos = TrainingVideoResult.watched_videos(current_user.id) if user_signed_in?

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
=begin    
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
=end    
    
    return popup
  end
  
  
  def prepare_search_text(text)
    text.strip.latinize.to_ascii.downcase
  end
end
