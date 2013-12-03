class Admin::VenueCategoriesController < ApplicationController
  before_filter :authenticate_user!
  before_filter do |controller_instance|
    controller_instance.send(:valid_role?, User::ROLES[:admin])
  end

  # GET /venue_categories
  # GET /venue_categories.json
  def index
    @venue_categories = VenueCategory.with_venues

    respond_to do |format|
      format.html # index.html.erb
      format.json { render json: @venue_categories }
    end
  end

  # GET /venue_categories/1
  # GET /venue_categories/1.json
  def show
    @venue_category = VenueCategory.with_venues(params[:id])

    respond_to do |format|
      format.html # show.html.erb
      format.json { render json: @venue_category }
    end
  end
  
  def venues
    if request.post?
      if params[:type] == "sort-order"
        # go through each sort item and if find one that changed, update the value
        Venue.update_sort_order(params[:sort_order_orig], params[:sort_order])
        flash[:notice] = t('app.msgs.updated_sort_order')
      elsif params[:type] == "new-venue"
        # create a new venue and add it to this category
        if params[:new_venue].present? && params[:id].present? && params[:new_venue][:name].present? &&
            (params[:new_venue][:name].values.uniq.length > 1 || 
            (params[:new_venue][:name].values.uniq.length == 1 && params[:new_venue][:name].values.uniq.first.present?))

          Venue.add_and_assign_new_venue(params[:new_venue][:name], params[:id], params[:new_venue][:sort_order])

          flash[:notice] = t('app.msgs.added_new_venue')
        else
          flash[:warning] = t('app.msgs.missing_required')
        end
      end
    end  

    @venue_category = VenueCategory.with_venues(params[:id])

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
