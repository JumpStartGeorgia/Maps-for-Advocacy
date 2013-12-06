class Admin::PlacesController < ApplicationController
  before_filter :authenticate_user!
  before_filter do |controller_instance|
    controller_instance.send(:valid_role?, User::ROLES[:admin])
  end

  # GET /places
  # GET /places.json
  def index
    @places = Place.all

    respond_to do |format|
      format.html # index.html.erb
      format.json { render json: @places }
    end
  end

  # GET /places/1
  # GET /places/1.json
  def show
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
      format.html # show.html.erb
      format.json { render json: @place }
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
      @venue_categories = VenueCategory.with_venues
    elsif params[:stage] == '2' # map
      @show_map = true
      gon.show_place_form_map = true
      gon.address_search_path = address_search_admin_places_path
    elsif params[:stage] == '3' # evaluation
      @place.venue_id = params[:venue_id]
      @place.lat = params[:lat]
      @place.lon = params[:lon]
      gon.show_evaluation_form = true
      
      # create the translation object for however many locales there are
      # so the form will properly create all of the nested form fields
      I18n.available_locales.each do |locale|
			  @place.place_translations.build(:locale => locale.to_s)
		  end
		
		  # get list of questions
		  @question_categories = QuestionCategory.questions_for_venue(@venue.question_category_id)
		  
		  # create the evaluation object for however many questions there are
		  if @question_categories.present?
        (0..@question_categories.length-1).each do |index|
  		    @place.place_evaluations.build(:user_id => current_user.id, :answer => 0)
		    end
		  end
    end

    respond_to do |format|
      format.html # new.html.erb
      format.json { render json: @place }
    end
  end

  # GET /places/1/edit
  def edit
    @place = Place.find(params[:id])
    params[:stage] = '3' if params[:stage].blank?
    gon.show_evaluation_form = true
    gon.address_search_path = address_search_admin_places_path

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

  # POST /places
  # POST /places.json
  def create
    @place = Place.new(params[:place])

    add_missing_translation_content(@place.place_translations)

    respond_to do |format|
      if @place.save
        format.html { redirect_to admin_place_path(@place), notice: t('app.msgs.success_created', :obj => t('activerecord.models.place')) }
        format.json { render json: @place, status: :created, location: @place }
      else
        gon.show_evaluation_form = true
        gon.address_search_path = address_search_admin_places_path
        params[:stage] = '3'
	      # get venue
	      @venue = Venue.with_translations(I18n.locale).find_by_id(@place.venue_id)
		    # get list of questions
		    @question_categories = QuestionCategory.questions_for_venue(@venue.question_category_id)
        format.html { render action: "new" }
        format.json { render json: @place.errors, status: :unprocessable_entity }
      end
    end
  end

  # PUT /places/1
  # PUT /places/1.json
  def update
    @place = Place.find(params[:id])

    @place.assign_attributes(params[:place])

    add_missing_translation_content(@place.place_translations)

    respond_to do |format|
      if @place.save
        format.html { redirect_to admin_place_path(@place), notice: t('app.msgs.success_updated', :obj => t('activerecord.models.place')) }
        format.json { head :ok }
      else
        gon.show_evaluation_form = true
        gon.address_search_path = address_search_admin_places_path
        params[:stage] = '3'
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
      format.html { redirect_to admin_places_url }
      format.json { head :ok }
    end
  end


  # use geocoder gem to get coords of address
  def address_search
    coords = []
    if params[:address].present?
		  begin
			  locations = Geocoder.search("#{params[:address]}")
Rails.logger.debug "/////////////////// results = #{locations.inspect}"
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
Rails.logger.debug "/////////////////// results = #{locations.inspect}"
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

Rails.logger.debug "/////////////////// returning: #{coords}"

    respond_to do |format|
      format.json { render json: coords.to_json }
    end
  end
end
