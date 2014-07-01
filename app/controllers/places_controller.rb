class PlacesController < ApplicationController
  before_filter :authenticate_user!, :except => :show

  # GET /places/1
  # GET /places/1.json
  def show
    @place = Place.with_translation(params[:id]).first
    @data = {:certified => {:summary => [], :summary_questions => [], :disability_evaluations => []}, 
             :public => {:summary => [], :summary_questions => [], :disability_evaluations => []}}
    @disability_evaluations = []
    
    if @place.present?
      if @place.lat.present? && @place.lon.present?
        @show_map = true
        gon.show_place_map = true

        gon.lat = @place.lat
        gon.lon = @place.lon
        gon.marker_popup = "<h3>#{@place[:place]}</h3><h4>#{@place[:venue]}</h4><p>#{@place[:address]}</p>"
        
      end    

      # get imgaes
      @place_images = PlaceImage.by_place(params[:id]).with_user.sorted
      
      certified_overall_question_categories = QuestionCategory.questions_categories_for_venue(question_category_id: @place.custom_question_category_id, is_certified: true, venue_id: @place.venue_id)
#      public_overall_question_categories = QuestionCategory.questions_categories_for_venue(question_category_id: @place.custom_public_question_category_id, is_certified: false)
      public_overall_question_categories = QuestionCategory.questions_for_venue(question_category_id: @place.custom_public_question_category_id, is_certified: false, venue_id: @place.venue_id)

      # get overall summary
      @data[:certified][:summary] = PlaceSummary.for_place_disablity(params[:id], is_certified: true)
      @data[:certified][:summary_questions] = certified_overall_question_categories
      @data[:public][:summary] = PlaceSummary.for_place_disablity(params[:id], is_certified: false)
      @data[:public][:summary_questions] = public_overall_question_categories

      # get the disabilities
      @disabilities_public = Disability.sorted.is_active_public
      @disabilities_certified = Disability.sorted.is_active_certified

      # get certified evaluations
      if @disabilities_certified.present?
        @disabilities_certified.each do |disability|
          qc_cert = QuestionCategory.questions_for_venue(question_category_id: @place.custom_question_category_id, disability_id: disability.id, is_certified: true, venue_id: @place.venue_id)

          c = Hash.new
          @data[:certified][:disability_evaluations] << c

          # record the disability
          c[:id] = disability.id
          c[:code] = disability.code
          c[:name] = disability.name

          c[:question_categories] = qc_cert

          # get evaluation results
          c[:evaluations] = PlaceEvaluation.with_answers(params[:id], disability_id: disability.id, is_certified: true).sorted
          c[:evaluation_count] = 0
          
          if c[:evaluations].present?
            c[:evaluation_count] = c[:evaluations].length
   
            # create summaries of evaluations
            c[:summaries] = PlaceSummary.for_place_disablity(params[:id], disability_id: disability.id, is_certified: true)
            
            # get user info that submitted evaluations
            c[:users] = User.for_evaluations(c[:evaluations].map{|x| x.user_id}.uniq)
          end        
        end
      end


      # get public evaluations
      if @disabilities_public.present?
        @disabilities_public.each do |disability|
          qc_public = QuestionCategory.questions_for_venue(question_category_id: @place.custom_public_question_category_id, disability_id: disability.id, is_certified: false, venue_id: @place.venue_id)

          p = Hash.new
          @data[:public][:disability_evaluations] << p
          
          # record the disability
          p[:id] = disability.id
          p[:code] = disability.code
          p[:name] = disability.name

          p[:question_categories] = qc_public

          # get evaluation results
          p[:evaluations] = PlaceEvaluation.with_answers(params[:id], disability_id: disability.id, is_certified: false).sorted
          p[:evaluation_count] = 0
          
          if p[:evaluations].present?
            p[:evaluation_count] = p[:evaluations].length
   
            # create summaries of evaluations
            p[:summaries] = PlaceSummary.for_place_disablity(params[:id], disability_id: disability.id, is_certified: false)
            
            # get user info that submitted evaluations
            p[:users] = User.for_evaluations(p[:evaluations].map{|x| x.user_id}.uniq)
          end        
        end
      end
      

      respond_to do |format|
        format.html # show.html.erb
        format.json { render json: @place }
      end
    else
			flash[:info] =  t('app.msgs.does_not_exist')
			redirect_to root_path(:locale => I18n.locale)
			return
    end
  end

  # GET /places/new
  # GET /places/new.json
  def new
    @place = Place.new
    params[:stage] = '1' if params[:stage].blank?

	  # get venue
	  @venue = Venue.with_translations(I18n.locale).find_by_id(params[:venue_id]) if params[:venue_id].present?

    if params[:stage] == '1' # venues
      gon.place_form_venue_filter = true
      gon.place_form_venue_num_match = t('places.form.venue_filter_num_match')
      @venue_categories = VenueCategory.with_venues
    elsif params[:stage] == '2' # name
      gon.show_place_name_form = true
    elsif params[:stage] == '3' # map
      @show_map = true
      gon.show_place_form_map = true
      gon.address_search_path = address_search_places_path
      gon.near_venue_id = @venue.id

      @place.venue_id = params[:venue_id]
      # create the translation object for however many locales there are
      # so the form will properly create all of the nested form fields
      I18n.available_locales.each do |locale|
			  @place.place_translations.build(:locale => locale.to_s, :name => params[:name])
		  end
    end

    respond_to do |format|
      format.html # new.html.erb
      format.json { render json: @place }
    end
  end
  
=begin
  # GET /places/1/edit
  def edit
    @place = Place.find(params[:id])
    params[:stage] = '5' if params[:stage].blank?
    gon.show_evaluation_form = true
    gon.address_search_path = address_search_places_path

	  # get venue
	  @venue = Venue.with_translations(I18n.locale).find_by_id(@place.venue_id)

	  # get list of questions
	  @question_categories = QuestionCategory.questions_for_venue(@venue.question_category_id)

	  # create the evaluation object for however many questions there are
	  if @question_categories.present?
      (0..@question_categories.length-1).each do |index|
		    @place.place_evaluations.build(:user_id => current_user.id, :answer => 0)
	    end
	  end
  end
=end

  # POST /places
  # POST /places.json
  def create
    @place = Place.new(params[:place])

    add_missing_translation_content(@place.place_translations)

    respond_to do |format|
      if @place.save
        format.html { redirect_to place_path(@place), notice: t('app.msgs.success_created', :obj => t('activerecord.models.place')) }
        format.json { render json: @place, status: :created, location: @place }
      else
        params[:stage] = '3'
	      # get venue
	      @venue = Venue.with_translations(I18n.locale).find_by_id(@place.venue_id)

        @show_map = true
        gon.show_place_form_map = true
        gon.address_search_path = address_search_places_path
        gon.near_venue_id = @venue.id
=begin
		    # get list of questions
  		  @question_categories = QuestionCategory.questions_for_venue(question_category_id: @venue.question_category_id, disability_id: params[:eval_type_id])
        # get disability
        @disability = Disability.with_name(params[:eval_type_id])
        @place_evaluation = @place.place_evaluations.first
=end                
        format.html { render action: "new" }
        format.json { render json: @place.errors, status: :unprocessable_entity }
      end
    end
  end
=begin
  # PUT /places/1
  # PUT /places/1.json
  def update
    @place = Place.find(params[:id])

    @place.assign_attributes(params[:place])

    add_missing_translation_content(@place.place_translations)

    respond_to do |format|
      if @place.save
        format.html { redirect_to place_path(@place), notice: t('app.msgs.success_updated', :obj => t('activerecord.models.place')) }
        format.json { head :ok }
      else
        gon.show_evaluation_form = true
        gon.address_search_path = address_search_places_path
        params[:stage] = '5'
	      # get venue
	      @venue = Venue.with_translations(I18n.locale).find_by_id(@place.venue_id)
		    # get list of questions
		    @question_categories = QuestionCategory.questions_for_venue(@venue.question_category_id)
        format.html { render action: "edit" }
        format.json { render json: @place.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /places/1
  # DELETE /places/1.json
  def destroy
    @place = Place.find(params[:id])
    @place.destroy

    respond_to do |format|
      format.html { redirect_to root_url }
      format.json { head :ok }
    end
  end
=end

  # use geocoder gem to get coords of address
  def address_search
    coords = []
    places_near = []
    if params[:address].present?
		  begin
			  locations = Geocoder.search("#{params[:address]}")
        if locations.present?
          locations.each do |l|
            x = Hash.new
            x[:coordinates] = l.coordinates
            x[:address] = l.address
            coords << x
          end
        end
		  rescue
			  coords = []
		  end
    elsif params[:lat].present? && params[:lon].present?
		  begin
			  locations = Geocoder.search("#{params[:lat]}, #{params[:lon]}")
        if locations.present?
          locations.each do |l|
            x = Hash.new
            x[:coordinates] = l.coordinates
            x[:address] = l.address
            coords << x
          end
        end
		  rescue
			  coords = []
		  end
    end
    
    if params[:near_venue_id].present? && coords.present?
    logger.debug "************ #{coords}"
      x = Place.get_places_near(coords[0][:coordinates][0], coords[0][:coordinates][1], params[:near_venue_id])
      if x.present?
        x.each do |place|
          marker = Hash.new
          marker['id'] = place.id
          marker['lat'] = place.lat
          marker['lon'] = place.lon
          marker['popup'] = create_popup_text(place)
          marker['list'] = create_list_text(place)
          places_near << marker
        end
      end
    end

    respond_to do |format|
      format.json { render json: {matches: coords, places_near: places_near}.to_json }
    end
  end
  
  
  
  # let user submit evaluation for an existing place
  def evaluation
    @place = Place.with_translation(params[:id]).first
    
    success = false
    
    if @place.present?
      if request.put?
        # save the evaluation
        @place.assign_attributes(params[:place])

        add_missing_translation_content(@place.place_translations)
            
        success = @place.save

      end

      if success
		    redirect_to place_path(@place), notice: t('app.msgs.success_created', :obj => t('activerecord.models.evaluation')) 
		    return
      else
		    if params[:certification].blank? && current_user.role?(User::ROLES[:certification])
          # the user can submit certified evals so see if they want to or not
          params[:stage] = '1'
        else      
          # init value
          params[:stage] = '2' if params[:stage].blank?

          # set certification value, default to false if not exist
          params[:certification] = !!(params[:certification] =~ (/^(true|t|yes|y|1)$/i))
        
          # if stage is 2 but eval type already exists, set stage to 3
          # - this happens if user clicks on link to evaluate a place by a specific eval type
          params[:stage] = '3' if params[:stage] == '2' && params[:eval_type_id].present?
        
          if params[:stage] == '2' || params[:eval_type_id].blank? # eval type
            @disabilities = Disability.sorted.is_active_public
            @disabilities = Disability.sorted.is_active_certified if params[:certification] == true
          elsif params[:stage] == '3' # eval form
            @disability = nil
            # make sure the eval type is active
            if params[:certification] == true
              @disability = Disability.is_active_certified.with_name(params[:eval_type_id])
            else
              @disability = Disability.is_active_public.with_name(params[:eval_type_id])
            end
            
            if @disability.blank?
              # disability could not be found, show the form again
              params[:stage] = '2'
              @disabilities = Disability.sorted.is_active_public
              @disabilities = Disability.sorted.is_active_certified if params[:certification] == true
            else
              # load the evaluation form js
              gon.show_evaluation_form = true

	            # get list of questions
              qc_id = @place.custom_question_category_id
              if !params[:certification]
                qc_id = @place.custom_public_question_category_id
              end
	            @question_categories = QuestionCategory.questions_for_venue(question_category_id: qc_id, disability_id: params[:eval_type_id], is_certified: params[:certification], venue_id: @place.venue_id)
              
		          # create the evaluation object for however many questions there are
		          if @question_categories.present?
		            @place_evaluation = @place.place_evaluations.build(user_id: current_user.id, disability_id: params[:eval_type_id], is_certified: params[:certification])
		            num_questions = QuestionCategory.number_questions(@question_categories)
		            if num_questions > 0
                  (0..num_questions-1).each do |index|
            		    @place_evaluation.place_evaluation_answers.build(:answer => PlaceEvaluation::ANSWERS['no_answer'])
		              end
                end
		          end
            end          
          end
        end
      end

      respond_to do |format|
        format.html # show.html.erb
        format.json { render json: @place }
      end
    else
		  flash[:info] =  t('app.msgs.does_not_exist')
		  redirect_to root_path(:locale => I18n.locale)
		  return
    end
  end
  
  ################################################
  ###### image processing ###################
  ################################################
  # upload images for a place
  def upload_photos
    @place = Place.with_translation(params[:id]).first
    gon.load_place_photos_path = upload_photos_place_url(:id => @place.id, :format => :json)
    @place_image_count = @place.place_images.count

    Rails.logger.debug "///////////////////// #{place_destroy_photo_path(:id => 16, :place_id => 3)}"

    if @place.present?
      respond_to do |format|
        format.html # show.html.erb
        format.json { render json: @place.place_images.map{|upload| upload.to_jq_upload } }
      end
    else
		  flash[:info] =  t('app.msgs.does_not_exist')
		  redirect_to root_path(:locale => I18n.locale)
		  return
    end
  
  end
  
  # upload images for a place
  def upload_photos_post
    @place = Place.with_translation(params[:id]).first

    if @place.present? 
      @place_image = @place.place_images.create(:image => params[:place_image][:image], :user_id => current_user.id)

      respond_to do |format|
        format.html {
          render :json => [@place_image.to_jq_upload].to_json,
          :content_type => 'text/html',
          :layout => false
        }
        format.json { render json: {files: [@place_image.to_jq_upload]}, status: :created, location: upload_photos_place_path(@place) }
      end
    else
		  flash[:info] =  t('app.msgs.does_not_exist')
		  redirect_to root_path(:locale => I18n.locale)
		  return
    end
  
  end

  # DELETE /places/1
  # DELETE /places/1.json
  def destroy_photo
    @place_image = PlaceImage.find(params[:id])
    @place_image.destroy

    respond_to do |format|
      format.html { redirect_to place_url(params[:place_id]) }
      format.json { head :no_content }
    end
  end
  
  
  private
  
  
  def create_popup_text(place)
    popup = ''
    popup << "<h3>#{place.name}</h3>"
    popup << "<h4>#{place.venue.name}</h4>"
    popup << "<p>#{place.address}</p>"

    popup << "<p>"
    popup << view_context.link_to(t('app.common.view_place'), place_path(place.id), :title => t('app.common.view_place_title', :place => place.name), :class => 'view_more')
    popup << " "
    popup << view_context.link_to(t('app.common.add_evaluation'), evaluation_place_path(place), :title => t('app.common.add_evaluation_title', :place => place.name), :class => 'add_evaluation')
    popup << "</p>"
    
    return popup
  end  
  
  def create_list_text(place)
    list = ''
    list << "<h3>#{place.name}</h3>"
    list << "<h4>#{place.venue.name}</h4>"
    list << "<p>#{place.address}</p>"

    list << "<p>"
    list << view_context.link_to(t('app.common.view_place'), place_path(place.id), :title => t('app.common.view_place_title', :place => place.name), :class => 'view_more')
    list << " "
    list << view_context.link_to(t('app.common.add_evaluation'), evaluation_place_path(place), :title => t('app.common.add_evaluation_title', :place => place.name), :class => 'add_evaluation')
    list << "</p>"
    
    return list
  end  
  
end
