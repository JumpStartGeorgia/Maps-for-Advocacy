class Admin::TrainingVideosController < ApplicationController
  before_filter :authenticate_user!
  before_filter do |controller_instance|
    controller_instance.send(:valid_role?, User::ROLES[:site_admin])
  end

  # GET /training_videos
  # GET /training_videos.json
  def index
    @training_videos = TrainingVideo.sorted

    respond_to do |format|
      format.html # index.html.erb
      format.json { render json: @training_videos }
    end
  end

  # GET /training_videos/1
  # GET /training_videos/1.json
  def show
    @training_video = TrainingVideo.find(params[:id])

    respond_to do |format|
      format.html # show.html.erb
      format.json { render json: @training_video }
    end
  end

  # GET /training_videos/new
  # GET /training_videos/new.json
  def new
    @training_video = TrainingVideo.new

    # create the translation object for however many locales there are
    # so the form will properly create all of the nested form fields
    I18n.available_locales.each do |locale|
      @training_video.training_video_translations.build(:locale => locale.to_s)
    end

    respond_to do |format|
      format.html # new.html.erb
      format.json { render json: @training_video }
    end
  end

  # GET /training_videos/1/edit
  def edit
    @training_video = TrainingVideo.find(params[:id])
  end

  # POST /training_videos
  # POST /training_videos.json
  def create
    @training_video = TrainingVideo.new(params[:training_video])

    add_missing_translation_content(@training_video.training_video_translations)

    respond_to do |format|
      if @training_video.save
        format.html { redirect_to admin_training_video_path(@training_video), notice: t('app.msgs.success_created', :obj => t('activerecord.models.training_video')) }
        format.json { render json: @training_video, status: :created, location: @training_video }
      else
        format.html { render action: "new" }
        format.json { render json: @training_video.errors, status: :unprocessable_entity }
      end
    end
  end

  # PUT /training_videos/1
  # PUT /training_videos/1.json
  def update
    @training_video = TrainingVideo.find(params[:id])

    @training_video.assign_attributes(params[:training_video])

    add_missing_translation_content(@training_video.training_video_translations)

    respond_to do |format|
      if @training_video.save
        format.html { redirect_to admin_training_video_path(@training_video), notice: t('app.msgs.success_updated', :obj => t('activerecord.models.training_video')) }
        format.json { head :ok }
      else
        format.html { render action: "edit" }
        format.json { render json: @training_video.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /training_videos/1
  # DELETE /training_videos/1.json
  def destroy
    @training_video = TrainingVideo.find(params[:id])
    @training_video.destroy

    respond_to do |format|
      format.html { redirect_to admin_training_videos_url }
      format.json { head :ok }
    end
  end
end
