class Admin::VenueCategoriesController < ApplicationController
  before_filter :authenticate_user!
  before_filter do |controller_instance|
    controller_instance.send(:valid_role?, User::ROLES[:admin])
  end

  # GET /venue_categories
  # GET /venue_categories.json
  def index
    @venue_categories = VenueCategory.all

    respond_to do |format|
      format.html # index.html.erb
      format.json { render json: @venue_categories }
    end
  end

  # GET /venue_categories/1
  # GET /venue_categories/1.json
  def show
    @venue_category = VenueCategory.find(params[:id])

    respond_to do |format|
      format.html # show.html.erb
      format.json { render json: @venue_category }
    end
  end

  # GET /venue_categories/new
  # GET /venue_categories/new.json
  def new
    @venue_category = VenueCategory.new
    # create the translation object for however many locales there are
    # so the form will properly create all of the nested form fields
    I18n.available_locales.each do |locale|
			@venue_category.venue_category_translations.build(:locale => locale.to_s)
		end

    respond_to do |format|
      format.html # new.html.erb
      format.json { render json: @venue_category }
    end
  end

  # GET /venue_categories/1/edit
  def edit
    @venue_category = VenueCategory.find(params[:id])
  end

  # POST /venue_categories
  # POST /venue_categories.json
  def create
    @venue_category = VenueCategory.new(params[:venue_category])

    add_missing_translation_content(@venue_category.venue_category_translations)

    respond_to do |format|
      if @venue_category.save
        format.html { redirect_to admin_venue_category_path(@venue_category), notice: t('app.msgs.success_created', :obj => t('activerecord.models.venue_category')) }
        format.json { render json: @venue_category, status: :created, location: @venue_category }
      else
        format.html { render action: "new" }
        format.json { render json: @venue_category.errors, status: :unprocessable_entity }
      end
    end
  end

  # PUT /venue_categories/1
  # PUT /venue_categories/1.json
  def update
    @venue_category = VenueCategory.find(params[:id])

    @venue_category.assign_attributes(params[:venue_category])

    add_missing_translation_content(@venue_category.venue_category_translations)

    respond_to do |format|
      if @venue_category.save
        format.html { redirect_to admin_venue_category_path(@venue_category), notice: t('app.msgs.success_updated', :obj => t('activerecord.models.venue_category')) }
        format.json { head :ok }
      else
        format.html { render action: "edit" }
        format.json { render json: @venue_category.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /venue_categories/1
  # DELETE /venue_categories/1.json
  def destroy
    @venue_category = VenueCategory.find(params[:id])
    @venue_category.destroy

    respond_to do |format|
      format.html { redirect_to admin_venue_categories_url }
      format.json { head :ok }
    end
  end
end
