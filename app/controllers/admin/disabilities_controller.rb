class Admin::DisabilitiesController < ApplicationController
  before_filter :authenticate_user!
  before_filter do |controller_instance|
    controller_instance.send(:valid_role?, User::ROLES[:site_admin])
  end

  # GET /disabilities
  # GET /disabilities.json
  def index
    @disabilities = Disability.sorted

    respond_to do |format|
      format.html # index.html.erb
      format.json { render json: @disabilities }
    end
  end

  # GET /disabilities/1
  # GET /disabilities/1.json
  def show
    @disability = Disability.find(params[:id])

    respond_to do |format|
      format.html # show.html.erb
      format.json { render json: @disability }
    end
  end

  # GET /disabilities/new
  # GET /disabilities/new.json
  def new
    @disability = Disability.new

    # create the translation object for however many locales there are
    # so the form will properly create all of the nested form fields
    I18n.available_locales.each do |locale|
			@disability.disability_translations.build(:locale => locale.to_s)
		end

    respond_to do |format|
      format.html # new.html.erb
      format.json { render json: @disability }
    end
  end

  # GET /disabilities/1/edit
  def edit
    @disability = Disability.find(params[:id])
  end

  # POST /disabilities
  # POST /disabilities.json
  def create
    @disability = Disability.new(params[:disability])

    add_missing_translation_content(@disability.disability_translations)

    respond_to do |format|
      if @disability.save
        format.html { redirect_to admin_disability_path(@disability), notice: t('app.msgs.success_created', :obj => t('activerecord.models.disability')) }
        format.json { render json: @disability, status: :created, location: @disability }
      else
        format.html { render action: "new" }
        format.json { render json: @disability.errors, status: :unprocessable_entity }
      end
    end
  end

  # PUT /disabilities/1
  # PUT /disabilities/1.json
  def update
    @disability = Disability.find(params[:id])

    @disability.assign_attributes(params[:disability])

    add_missing_translation_content(@disability.disability_translations)

    respond_to do |format|
      if @disability.save
        format.html { redirect_to admin_disability_path(@disability), notice: t('app.msgs.success_updated', :obj => t('activerecord.models.disability')) }
        format.json { head :ok }
      else
        format.html { render action: "edit" }
        format.json { render json: @disability.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /disabilities/1
  # DELETE /disabilities/1.json
  def destroy
    @disability = Disability.find(params[:id])
    @disability.destroy

    respond_to do |format|
      format.html { redirect_to admin_disabilities_url }
      format.json { head :ok }
    end
  end
end
