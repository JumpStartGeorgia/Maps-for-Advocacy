class PlacesController < ApplicationController
  before_filter :authenticate_user!, :except => [:show, :evaluation_details]
  before_filter :only => [:edit, :update, :delete] do |controller_instance|
    controller_instance.send(:valid_role?, User::ROLES[:site_admin])
  end


  def show
    @place = Place.with_translation(params[:id]).first
    @data = {:certified => {:summary => [], :summary_questions => [], :disability_evaluations => []}, 
             :public => {:summary => [], :summary_questions => [], :disability_evaluations => []}}

    gon.show_place_images = true
    
    if @place.present?
      if @place.lat.present? && @place.lon.present?
        @show_map = true
        gon.show_place_map = true

        gon.lat = @place.lat
        gon.lon = @place.lon
        gon.marker_popup = "<h3>#{@place[:place]}</h3><h4>#{@place[:venue]}</h4><p>#{@place[:address]}</p>"
        
      end    

      # get imgaes
      @place_images = PlaceImage.by_place(params[:id])
      
      certified_overall_question_categories = QuestionCategory.questions_categories_for_venue(question_category_id: @place.custom_question_category_id, is_certified: true, venue_id: @place.venue_id)
#      public_overall_question_categories = QuestionCategory.questions_categories_for_venue(question_category_id: @place.custom_public_question_category_id, is_certified: false)
      public_overall_question_categories = QuestionCategory.questions_for_venue(question_category_id: @place.custom_public_question_category_id, is_certified: false, venue_id: @place.venue_id)

      # get overall summary
      @data[:certified][:summary] = PlaceSummary.for_place_disablity(params[:id], is_certified: true)
      @data[:certified][:summary_questions] = certified_overall_question_categories
      @data[:public][:summary] = PlaceSummary.for_place_disablity(params[:id], is_certified: false)
      @data[:public][:summary_questions] = public_overall_question_categories

      # get the disabilities
      @disabilities = Disability.sorted.is_active
      disabilities_public = @disabilities.select{|x| x.active_public == true}
      disabilities_certified = @disabilities.select{|x| x.active_certified == true}

      # get certified evaluations
      if disabilities_certified.present?
        disabilities_certified.each do |disability|
          qc_cert = QuestionCategory.questions_for_venue(question_category_id: @place.custom_question_category_id, disability_id: disability.id, is_certified: true, venue_id: @place.venue_id)

          c = Hash.new
          @data[:certified][:disability_evaluations] << c

          # record the disability
          c[:id] = disability.id
          c[:code] = disability.code
          c[:name] = disability.name

          c[:evaluation_count] = PlaceEvaluation.with_answers(params[:id], disability_id: disability.id, is_certified: true).count

          c[:question_categories] = qc_cert

          # create summaries of evaluations
          c[:summaries] = PlaceSummary.for_place_disablity(params[:id], disability_id: disability.id, is_certified: true)
        end
      end


      # get public evaluations
      if disabilities_public.present?
        disabilities_public.each do |disability|
          qc_public = QuestionCategory.questions_for_venue(question_category_id: @place.custom_public_question_category_id, disability_id: disability.id, is_certified: false, venue_id: @place.venue_id)

          p = Hash.new
          @data[:public][:disability_evaluations] << p
          
          # record the disability
          p[:id] = disability.id
          p[:code] = disability.code
          p[:name] = disability.name

          p[:evaluation_count] = PlaceEvaluation.with_answers(params[:id], disability_id: disability.id, is_certified: false).count

          p[:question_categories] = qc_public

          # create summaries of evaluations
          p[:summaries] = PlaceSummary.for_place_disablity(params[:id], disability_id: disability.id, is_certified: false)
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

  # show evaluation results for a place
  # - params: is_certified, type
  def evaluation_details
    @place = Place.with_translation(params[:id]).first
    @data = {:summary_questions => [], :evaluations => []}

    @is_certified = params[:is_certified].to_bool
    disabilities = nil
    if params[:type].present?
      if @is_certified == true
        disabilities = [Disability.is_active_certified.find_by_id(params[:type])]
      else
        disabilities = [Disability.is_active_public.find_by_id(params[:type])]
      end
    else
      if @is_certified == true
        disabilities = Disability.is_active_certified
      else
        disabilities = Disability.is_active_public
      end
    end

    if @place.present? && disabilities.present?
      # get summary questions
      if @is_certified
        @data[:summary_questions] = QuestionCategory.questions_categories_for_venue(question_category_id: @place.custom_question_category_id, is_certified: true, venue_id: @place.venue_id)
      else
        @data[:summary_questions] = QuestionCategory.questions_for_venue(question_category_id: @place.custom_public_question_category_id, is_certified: false, venue_id: @place.venue_id)
      end
      
      disabilities.each do |disability|
        # get evaluation results
        evals = PlaceEvaluation.with_answers(params[:id], disability_id: disability.id, is_certified: @is_certified).sorted
        
        # only record info if this disability has evaluations        
        if evals.present?
          qc = QuestionCategory.questions_for_venue(question_category_id: @place.custom_question_category_id, disability_id: disability.id, is_certified: @is_certified, venue_id: @place.venue_id)

          eval = Hash.new
          @data[:evaluations] << eval

          # record the disability
          eval[:id] = disability.id
          eval[:code] = disability.code
          eval[:name] = disability.name

          eval[:question_categories] = qc

          # get evaluation results
          eval[:evaluations] = evals
          eval[:evaluation_count] = 0
          
          if eval[:evaluations].present?
            eval[:evaluation_count] = eval[:evaluations].length

            # create summaries of evaluations
            eval[:summaries] = PlaceSummary.for_place_disablity(params[:id], disability_id: disability.id, is_certified: @is_certified)
            
            # get user info that submitted evaluations
            eval[:users] = User.for_evaluations(eval[:evaluations].map{|x| x.user_id}.uniq)
          end        
        end
      end
    end

    respond_to do |format|
      format.html { render layout: 'fancybox'}
      format.json { render json: @data }
    end
  end

  # GET /places/1
  # GET /places/1.json
  def show2
    @place = Place.with_translation(params[:id]).first
    @data = {:certified => {:summary => [], :summary_questions => [], :disability_evaluations => []}, 
             :public => {:summary => [], :summary_questions => [], :disability_evaluations => []}}

    gon.show_place_images = true
    
    if @place.present?
      if @place.lat.present? && @place.lon.present?
        @show_map = true
        gon.show_place_map = true

        gon.lat = @place.lat
        gon.lon = @place.lon
        gon.marker_popup = "<h3>#{@place[:place]}</h3><h4>#{@place[:venue]}</h4><p>#{@place[:address]}</p>"
        
      end    

      # get imgaes
      @place_images = PlaceImage.by_place(params[:id])
      
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
    # create the translation object for however many locales there are
    # so the form will properly create all of the nested form fields
    I18n.available_locales.each do |locale|
		  @place.place_translations.build(:locale => locale.to_s)
	  end

    @venue_categories = VenueCategory.with_venues
    @show_map = true

    gon.show_place_form = true
    gon.address_search_path = address_search_places_path
    gon.near_venue_id = 0

    respond_to do |format|
      format.html # new.html.erb
      format.json { render json: @place }
    end
  end
  
  # GET /places/1/edit
  def edit
    @place = Place.find(params[:id])

    @venue_categories = VenueCategory.with_venues
    @show_map = true
    gon.show_place_form = true
    gon.edit_place_form = true
    gon.address_search_path = address_search_places_path
    gon.near_venue_id = @place.venue_id
    if @place.lat.present? && @place.lon.present?
      gon.lat = @place.lat
      gon.lon = @place.lon
    end

  end

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
        @place.name = params[:place][:name]
        @place.address = @place.place_translations.first.address
        @venue_categories = VenueCategory.with_venues
        @show_map = true

        gon.show_place_form = true
        gon.edit_place_form = true
        gon.default_address_selection_index = params[:address]
        gon.address_search_path = address_search_places_path
        gon.near_venue_id = @place.venue_id
        if @place.lat.present? && @place.lon.present?
          gon.lat = @place.lat
          gon.lon = @place.lon
        end

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
        format.html { redirect_to place_path(@place), notice: t('app.msgs.success_updated', :obj => t('activerecord.models.place')) }
        format.json { head :ok }
      else
        @venue_categories = VenueCategory.with_venues
        @show_map = true
        gon.show_place_form = true
        gon.edit_place_form = true
        gon.default_address_selection_index = params[:address]
        gon.address_search_path = address_search_places_path
        gon.near_venue_id = @place.venue_id
        if @place.lat.present? && @place.lon.present?
          gon.lat = @place.lat
          gon.lon = @place.lon
        end

        format.html { render action: "edit" }
        format.json { render json: @place.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /places/1
  # DELETE /places/1.json
  def destroy
    @place = Place.find(params[:id])
    # delete the place and its evaluations
    @place.destroy
    # delete the summaries for this place
    PlaceSummary.where(:place_id => params[:id]).destroy_all

    respond_to do |format|
      format.html { redirect_to root_url }
      format.json { head :ok }
    end
  end

  # delete an evaluation for a place
  # DELETE /places/1/delete_evaluation/:evaluation_id
  def delete_evaluation
    @place = Place.find(params[:id])
    @evaluation = PlaceEvaluation.find(params[:evaluation_id])

    # if the records were found and the user is a site admin or is the owner of the eval,
    # contine
    if @place.present? && @evaluation.present? && 
        (current_user.role?(User::ROLES[:site_admin]) || current_user.id == @evaluation.user_id)
      is_certified = @evaluation.is_certified

      # delete the evaluation
      @evaluation.destroy

      # if no evals left in this type, delete summary for type
      # else run summary for type
      num_evals = PlaceEvaluation.where(:place_id => @place.id, :is_certified => is_certified).count

      if num_evals == 0
        # no evals left delete all summaries of this type for this places
        PlaceSummary.where(:place_id => @place.id, :is_certified => is_certified).destroy_all
      else
        # some evals of this type still exist, so recompute the summarries for this type
        if is_certified == true
          PlaceSummary.update_certified_summaries(@place.id)
        else
          PlaceSummary.update_summaries(@place.id)
        end
      end
    end

    respond_to do |format|
      format.html { redirect_to place_path(@place.id) }
      format.json { head :ok }
    end

  end

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

    # if session goto exists, remove it
    session[:goto_url] = nil if session[:goto_url].present?

    # record wether or not user has seen training video popup yet
    gon.show_training_popup = current_user.show_popup_training
    gon.saw_popup_path = saw_popup_path

    # make a copy of @place for saving
    # since loading blank eval objects into @place before saving
#    place_for_save = @place.dup

    if @place.present?
      @can_certify = current_user.role?(User::ROLES[:certification])
      @user_organizations_ids = current_user.organizations.present? ? current_user.organizations.map{|x| x.id} : nil
      @evaluation_types_public = Disability.sorted.is_active_public
      @evaluation_types_certified = Disability.sorted.is_active_certified
      
      if @evaluation_types_public.present?
        # get list of questions
        qc_id_public = @place.custom_public_question_category_id
        @question_categories_public = QuestionCategory.questions_for_venue(question_category_id: qc_id_public, disability_ids: @evaluation_types_public.map{|x| x.id}, is_certified: false, venue_id: @place.venue_id)
      end
      
      if @evaluation_types_certified.present? && @can_certify
        # get list of questions
        qc_id_certified = @place.custom_question_category_id
        @question_categories_certified = QuestionCategory.questions_for_venue(question_category_id: qc_id_certified, disability_ids: @evaluation_types_certified.map{|x| x.id}, is_certified: true, venue_id: @place.venue_id)
      end

      if request.get?
        # create the evaluation object for however many questions there are
        if @question_categories_public.present?
          @place_evaluation_public = @place.place_evaluations.build(user_id: current_user.id, disability_ids: @evaluation_types_public.map{|x| x.id}, is_certified: false)
=begin          
          if @user_organizations_ids.length > 0 && @place_evaluation_public.organizations.length < @user_organizations_ids.length
            (0..(@user_organizations_ids.length-@place_evaluation_public.organizations.length)).each do |item|
              @place_evaluation_public.organizations.build
            end
          end
=end          
          num_questions = QuestionCategory.number_questions(@question_categories_public)
          if num_questions > 0
            (0..num_questions-1).each do |index|
      		    @place_evaluation_public.place_evaluation_answers.build(:answer => PlaceEvaluation::ANSWERS['no_answer'])
      		    @place_evaluation_public.place_evaluation_images.build
            end
          end
        end
        
        # create the evaluation object for however many questions there are
        if @question_categories_certified.present?
          @place_evaluation_certified = @place.place_evaluations.build(user_id: current_user.id, disability_ids: @evaluation_types_certified.map{|x| x.id}, is_certified: true)
=begin          
          if @user_organizations_ids.length > 0 && @place_evaluation_certified.organizations.length < @user_organizations_ids.length
            (0..(@user_organizations_ids.length-@place_evaluation_certified.organizations.length)).each do |item|
              @place_evaluation_certified.organizations.build
            end
          end
=end          
          num_questions = QuestionCategory.number_questions(@question_categories_certified)
          if num_questions > 0
            (0..num_questions-1).each do |index|
      		    @place_evaluation_certified.place_evaluation_answers.build(:answer => PlaceEvaluation::ANSWERS['no_answer'])
      		    @place_evaluation_certified.place_evaluation_images.build
            end
          end
        end
        
      elsif request.put?
        success = false

        # for each disability id, pull out the answers that match it and save the evaluation
        ids = params[:place][:place_evaluations_attributes]['0'][:disability_ids]
        is_certified = params[:place][:place_evaluations_attributes]['0'][:is_certified].to_s.to_bool
        if is_certified && !@can_certify
          # TODO this is not good so catch and do something
        end
        
        if ids.present?
          # convert to array
          disability_ids = ids.gsub('[','').gsub(']','').split(',')
          
          # create place holder for result of evaluation saving
          success = Array.new(disability_ids.length, false)
          
          # pull out the question pairing id and the disability ids associated with it
          id_mappings = []      
          if disability_ids.present?
            if is_certified
              id_mappings = @question_categories_certified.map{|x| x[:questions]}.flatten!
                                  .map{|x| [x[:question_pairing_id], [x[:disability_id], x[:disability_ids].split(',')].flatten!]}     
            else
              id_mappings = @question_categories_public.map{|x| x[:questions]}.flatten!
                                  .map{|x| [x[:question_pairing_id], [x[:disability_id], x[:disability_ids].split(',')].flatten!]}     
            end  
          end

          place_params = nil
          if id_mappings.present?        
            # pull out any images that were included and save them first
            saved_images = []
            images_to_load = params[:place]['place_evaluations_attributes']['0']['place_evaluation_images_attributes']
                              .select{|k,v| v['images'].present?}.map{|k,v| v['images']}.flatten
            unique_image_names = images_to_load.map{|x| x.original_filename}.uniq if images_to_load.present?
            if unique_image_names.present?
              unique_image_names.each do |img|
                saved_images << PlaceImage.create(:user_id => current_user.id, :place_id => params[:id],
                                  :image => images_to_load.select{|x| x.original_filename == img}.first)
              end
            end

            # make copy of params and remove evalautions
            # new eval objects will be added for each disability
            place_params = params[:place].deep_dup
            place_params['place_evaluations_attributes'].delete('0')

            # pull out and format the org ids so they can be saved correctly
            org_ids = nil
            if params[:place]['place_evaluations_attributes']['0']['organization_ids'].present?
              org_ids = params[:place]['place_evaluations_attributes']['0']['organization_ids'].gsub('[','').gsub(']','').split(',').map{|x| x.strip}
            end
            

            disability_ids.each_with_index do |disability_id, idx_disability|
              # get the questions for this disability id
              qp_ids = id_mappings.select{|x| x[1].include?(disability_id.to_s)}.map{|x| x[0].to_s}
              
              if qp_ids.present?
                # create new eval attributes key
                place_params['place_evaluations_attributes'][idx_disability.to_s] = {}
        
                # add place eval variables
                place_params['place_evaluations_attributes'][idx_disability.to_s]['disability_id'] = disability_id
                place_params['place_evaluations_attributes'][idx_disability.to_s]['disability_other_text'] = params[:place]['place_evaluations_attributes']['0']['disability_other_text']
                place_params['place_evaluations_attributes'][idx_disability.to_s]['user_id'] = params[:place]['place_evaluations_attributes']['0']['user_id']
                place_params['place_evaluations_attributes'][idx_disability.to_s]['is_certified'] = params[:place]['place_evaluations_attributes']['0']['is_certified']
                place_params['place_evaluations_attributes'][idx_disability.to_s]['organization_ids'] = org_ids

                # pull questions/answers that are in qp_ids
                place_params['place_evaluations_attributes'][idx_disability.to_s]['place_evaluation_answers_attributes'] = 
                    params[:place]['place_evaluations_attributes']['0']['place_evaluation_answers_attributes']
                      .select{|k,v| qp_ids.include?(v['question_pairing_id'])}              
                      
                # pull images that exist and create record for each one (multiple can exist for one qp_id)
                # - unique images were already saved above, so for this we need to find a match and save the id
                if saved_images.present?
                  records_with_images = params[:place]['place_evaluations_attributes']['0']['place_evaluation_images_attributes']
                            .select{|k,v| qp_ids.include?(v['question_pairing_id']) && v['images'].present?}
                  if records_with_images.present?
                    place_params['place_evaluations_attributes'][idx_disability.to_s]['place_evaluation_images_attributes'] = {}
                    idx_image = 0
                    records_with_images.each do |key, record_with_image|

                      record_with_image['images'].each do |image|

                        # look for this image in the saved_images array
                        # - if found, use the id of image
                        # since the images are already saved, the file name was cleaned up by paperclip
                        # so apply same clean up procedure to do proper testing
                        image_index = saved_images.index{|x| x.image_file_name == image.original_filename.gsub(/[&$+,\/:;=?@<>\[\]\{\}\|\\\^~%# ]/, '_')}
                        if image_index.present?
                          place_params['place_evaluations_attributes'][idx_disability.to_s]['place_evaluation_images_attributes'][idx_image.to_s] = {}
                          place_params['place_evaluations_attributes'][idx_disability.to_s]['place_evaluation_images_attributes'][idx_image.to_s]['question_pairing_id'] = record_with_image['question_pairing_id']
                          place_params['place_evaluations_attributes'][idx_disability.to_s]['place_evaluation_images_attributes'][idx_image.to_s]['place_image_id'] = saved_images[image_index].id

                          idx_image += 1
                        end
                      end
                    
                    end
                  end
                end
              end
            end

            if place_params.present? && place_params['place_evaluations_attributes'].keys.length > 0
              # save!
              @place.assign_attributes(place_params)
              success = @place.save
            
              if success
		            redirect_to place_path(@place), notice: t('app.msgs.success_created', :obj => t('activerecord.models.evaluation')) 
		            return
              else
logger.debug "-------> error: #{@place.errors.full_messages}"                    
              end
            end
          end          
        end
      end

      # set gon variables for evidence evaluation messages
      gon.show_evaluation_form = true
      gon.no_evidence_entered = I18n.t('app.msgs.evidence_validation.no_evidence_entered')
      gon.no_evidence_entered_angle = I18n.t('app.msgs.evidence_validation.no_evidence_entered_angle')
      gon.no_units_entered = I18n.t('app.msgs.evidence_validation.no_units_entered')
      gon.units_not_match = I18n.t('app.msgs.evidence_validation.units_not_match')
      gon.units_not_match_angle = I18n.t('app.msgs.evidence_validation.units_not_match_angle')
      gon.validation_passed = I18n.t('app.msgs.evidence_validation.validation_passed')
      gon.validation_failed = I18n.t('app.msgs.evidence_validation.validation_failed')

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
  

  # record that the user saw the training video popup on evaluation page
  def saw_popup
    respond_to do |format|
      format.js { 
        if current_user.show_popup_training
          current_user.show_popup_training = false
          current_user.save
        end

        render nothing: true
      }
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
