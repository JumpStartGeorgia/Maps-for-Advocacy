class Admin::RightsController < ApplicationController
  before_filter :authenticate_user!
  before_filter do |controller_instance|
    controller_instance.send(:valid_role?, User::ROLES[:site_admin])
  end

  # GET /rights
  # GET /rights.json
  def index
    @rights = Right.sorted

    respond_to do |format|
      format.html # index.html.erb
      format.json { render json: @rights }
    end
  end

  # GET /rights/1
  # GET /rights/1.json
  def show
    @right = Right.find(params[:id])

    respond_to do |format|
      format.html # show.html.erb
      format.json { render json: @right }
    end
  end

  # GET /rights/new
  # GET /rights/new.json
  def new
    @right = Right.new

    # create the translation object for however many locales there are
    # so the form will properly create all of the nested form fields
    I18n.available_locales.each do |locale|
			@right.right_translations.build(:locale => locale.to_s)
		end


    respond_to do |format|
      format.html # new.html.erb
      format.json { render json: @right }
    end
  end

  # GET /rights/1/edit
  def edit
    @right = Right.find(params[:id])
  end

  # POST /rights
  # POST /rights.json
  def create
    @right = Right.new(params[:right])

    add_missing_translation_content(@right.right_translations)

    respond_to do |format|
      if @right.save
        format.html { redirect_to admin_rights_path, notice: t('app.msgs.success_created', :obj => t('activerecord.models.right')) }
        format.json { render json: @right, status: :created, location: @right }
      else
        format.html { render action: "new" }
        format.json { render json: @right.errors, status: :unprocessable_entity }
      end
    end
  end

  # PUT /rights/1
  # PUT /rights/1.json
  def update
    @right = Right.find(params[:id])

    @right.assign_attributes(params[:right])

    add_missing_translation_content(@right.right_translations)

    respond_to do |format|
      if @right.save
        format.html { redirect_to admin_rights_path, notice: t('app.msgs.success_updated', :obj => t('activerecord.models.right')) }
        format.json { head :ok }
      else
        format.html { render action: "edit" }
        format.json { render json: @right.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /rights/1
  # DELETE /rights/1.json
  def destroy
    @right = Right.find(params[:id])
    @right.destroy

    respond_to do |format|
      format.html { redirect_to admin_new_translations_url }
      format.json { head :ok }
    end
  end
end
