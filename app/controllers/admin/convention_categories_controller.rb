class Admin::ConventionCategoriesController < ApplicationController
  before_filter :authenticate_user!
  before_filter do |controller_instance|
    controller_instance.send(:valid_role?, User::ROLES[:site_admin])
  end

  # GET /convention_categories
  # GET /convention_categories.json
  def index
    @convention_categories = ConventionCategory.sorted

    respond_to do |format|
      format.html # index.html.erb
      format.json { render json: @convention_categories }
    end
  end

  # GET /convention_categories/1
  # GET /convention_categories/1.json
  def show
    @convention_category = ConventionCategory.find(params[:id])

    respond_to do |format|
      format.html # show.html.erb
      format.json { render json: @convention_category }
    end
  end

  # GET /convention_categories/new
  # GET /convention_categories/new.json
  def new
    @convention_category = ConventionCategory.new

    # create the translation object for however many locales there are
    # so the form will properly create all of the nested form fields
    I18n.available_locales.each do |locale|
			@convention_category.convention_category_translations.build(:locale => locale.to_s)
		end

    respond_to do |format|
      format.html # new.html.erb
      format.json { render json: @convention_category }
    end
  end

  # GET /convention_categories/1/edit
  def edit
    @convention_category = ConventionCategory.find(params[:id])
  end

  # POST /convention_categories
  # POST /convention_categories.json
  def create
    @convention_category = ConventionCategory.new(params[:convention_category])

    add_missing_translation_content(@convention_category.convention_category_translations)

    respond_to do |format|
      if @convention_category.save
        format.html { redirect_to admin_convention_categories_path, notice: t('app.msgs.success_created', :obj => t('activerecord.models.convention_category')) }
        format.json { render json: @convention_category, status: :created, location: @convention_category }
      else
        format.html { render action: "new" }
        format.json { render json: @convention_category.errors, status: :unprocessable_entity }
      end
    end
  end

  # PUT /convention_categories/1
  # PUT /convention_categories/1.json
  def update
    @convention_category = ConventionCategory.find(params[:id])

    @convention_category.assign_attributes(params[:convention_category])

    add_missing_translation_content(@convention_category.convention_category_translations)

    respond_to do |format|
      if @convention_category.save
        format.html { redirect_to admin_convention_categories_path, notice: t('app.msgs.success_updated', :obj => t('activerecord.models.convention_category')) }
        format.json { head :ok }
      else
        format.html { render action: "edit" }
        format.json { render json: @convention_category.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /convention_categories/1
  # DELETE /convention_categories/1.json
  def destroy
    @convention_category = ConventionCategory.find(params[:id])
    @convention_category.destroy

    respond_to do |format|
      format.html { redirect_to admin_convention_categories_url }
      format.json { head :ok }
    end
  end
end
