class Admin::QuestionPairingDisabilitiesController < ApplicationController
  before_filter :authenticate_user!
  before_filter do |controller_instance|
    controller_instance.send(:valid_role?, User::ROLES[:site_admin])
  end

  # GET /help_text
  # GET /help_text.json
  def index
    respond_to do |format|
      format.html {
        @disabilities = Disability.sorted.is_active
        @categories = QuestionCategory.all_main
      }
      format.json { render json: QuestionPairingDisabilitiesDatatable.new(view_context, params[:is_certified], params[:type], params[:category]) }
    end
  end

  # GET /help_text/1
  # GET /help_text/1.json
  def show
    @question_pairing_disability = QuestionPairingDisability.find(params[:id])

    respond_to do |format|
      format.html # show.html.erb
      format.json { render json: @question_pairing_disability }
    end
  end

  # # GET /help_text/new
  # # GET /help_text/new.json
  # def new
  #   @question_pairing_disability = QuestionPairingDisability.new

  #   # create the translation object for however many locales there are
  #   # so the form will properly create all of the nested form fields
  #   I18n.available_locales.each do |locale|
  #     @question_pairing_disability.question_pairing_disability_translations.build(:locale => locale.to_s)
  #   end

  #   respond_to do |format|
  #     format.html # new.html.erb
  #     format.json { render json: @question_pairing_disability }
  #   end
  # end

  # GET /help_text/1/edit
  def edit
    @question_pairing_disability = QuestionPairingDisability.find(params[:id])

    # create the translation object for whichever locales do not exist yet
    existing_locales = @question_pairing_disability.question_pairing_disability_translations.map{|x| x.locale}
    I18n.available_locales.each do |locale|
      if existing_locales.blank? || existing_locales.index(locale.to_s).nil?
        @question_pairing_disability.question_pairing_disability_translations.build(:locale => locale.to_s)
      end
    end

  end

  # # POST /help_text
  # # POST /help_text.json
  # def create
  #   @question_pairing_disability = QuestionPairingDisability.new(params[:question_pairing_disability])

  #   add_missing_translation_content(@question_pairing_disability.question_pairing_disability_translations)

  #   respond_to do |format|
  #     if @question_pairing_disability.save
  #       format.html { redirect_to admin_question_pairing_disability_path(@question_pairing_disability), notice: t('app.msgs.success_created', :obj => t('activerecord.models.question_pairing_disability')) }
  #       format.json { render json: @question_pairing_disability, status: :created, location: @question_pairing_disability }
  #     else
  #       format.html { render action: "new" }
  #       format.json { render json: @question_pairing_disability.errors, status: :unprocessable_entity }
  #     end
  #   end
  # end

  # PUT /help_text/1
  # PUT /help_text/1.json
  def update
    @question_pairing_disability = QuestionPairingDisability.find(params[:id])

logger.debug "!!!!!!!!!!!!!!! trans count = #{@question_pairing_disability.question_pairing_disability_translations.length}"

    @question_pairing_disability.assign_attributes(params[:question_pairing_disability])

    add_missing_translation_content(@question_pairing_disability.question_pairing_disability_translations)

logger.debug "!!!!!!!!!!!!!!! trans count after missing content = #{@question_pairing_disability.question_pairing_disability_translations.length}"

    respond_to do |format|
      if @question_pairing_disability.save
        format.html { redirect_to admin_question_pairing_disability_path(@question_pairing_disability), notice: t('app.msgs.success_updated', :obj => t('activerecord.models.question_pairing_disability')) }
        format.json { head :ok }
      else
        format.html { render action: "edit" }
        format.json { render json: @question_pairing_disability.errors, status: :unprocessable_entity }
      end
    end
  end

  # # DELETE /help_text/1
  # # DELETE /help_text/1.json
  # def destroy
  #   @question_pairing_disability = QuestionPairingDisability.find(params[:id])
  #   @question_pairing_disability.destroy

  #   respond_to do |format|
  #     format.html { redirect_to admin_question_pairing_disabilities_url }
  #     format.json { head :ok }
  #   end
  # end
end
