class Admin::QuestionCategoriesController < ApplicationController
  before_filter :authenticate_user!
  before_filter do |controller_instance|
    controller_instance.send(:valid_role?, User::ROLES[:admin])
  end

  # GET /question_categories
  # GET /question_categories.json
  def index
    @question_categories = QuestionCategory.all

    respond_to do |format|
      format.html # index.html.erb
      format.json { render json: @question_categories }
    end
  end

  # GET /question_categories/1
  # GET /question_categories/1.json
  def show
    @question_category = QuestionCategory.find(params[:id])

    respond_to do |format|
      format.html # show.html.erb
      format.json { render json: @question_category }
    end
  end

  # GET /question_categories/new
  # GET /question_categories/new.json
  def new
    @question_category = QuestionCategory.new
    # create the translation object for however many locales there are
    # so the form will properly create all of the nested form fields
    I18n.available_locales.each do |locale|
			@question_category.question_category_translations.build(:locale => locale.to_s)
		end

    respond_to do |format|
      format.html # new.html.erb
      format.json { render json: @question_category }
    end
  end

  # GET /question_categories/1/edit
  def edit
    @question_category = QuestionCategory.find(params[:id])
  end

  # POST /question_categories
  # POST /question_categories.json
  def create
    @question_category = QuestionCategory.new(params[:question_category])

    add_missing_translation_content(@question_category.question_category_translations)

    respond_to do |format|
      if @question_category.save
        format.html { redirect_to admin_question_category_path(@question_category), notice: t('app.msgs.success_created', :obj => t('activerecord.models.question_category')) }
        format.json { render json: @question_category, status: :created, location: @question_category }
      else
        format.html { render action: "new" }
        format.json { render json: @question_category.errors, status: :unprocessable_entity }
      end
    end
  end

  # PUT /question_categories/1
  # PUT /question_categories/1.json
  def update
    @question_category = QuestionCategory.find(params[:id])

    @question_category.assign_attributes(params[:question_category])

    add_missing_translation_content(@question_category.question_category_translations)

    respond_to do |format|
      if @question_category.save
        format.html { redirect_to admin_question_category_path(@question_category), notice: t('app.msgs.success_updated', :obj => t('activerecord.models.question_category')) }
        format.json { head :ok }
      else
        format.html { render action: "edit" }
        format.json { render json: @question_category.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /question_categories/1
  # DELETE /question_categories/1.json
  def destroy
    @question_category = QuestionCategory.find(params[:id])
    @question_category.destroy

    respond_to do |format|
      format.html { redirect_to admin_question_categories_url }
      format.json { head :ok }
    end
  end
end
