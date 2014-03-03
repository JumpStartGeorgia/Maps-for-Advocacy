class ReportsController < ApplicationController

  def index
    @places = PlaceSummary.stats_overall_place_evaluation_results
    @evals = PlaceSummary.stats_overall_evaluation_results
    @disabilities = Disability.is_active.sorted
    @general_stats = []
    @general_stats << {:name => I18n.t('reports.index.general.places'), :count => Place.count}
        @general_stats << {:name => I18n.t('reports.index.general.certified'), :count => @evals.present? && @evals.has_key?(:certified) && @evals[:certified].has_key?(:total) ? @evals[:certified][:total][:total] : 0}
        @general_stats << {:name => I18n.t('reports.index.general.public'), :count => @evals.present? && @evals.has_key?(:public) && @evals[:public].has_key?(:total) ? @evals[:public][:total][:total] : 0}
    @general_stats << {:name => I18n.t('reports.index.general.answers'), :count => PlaceEvaluationAnswer.answer_count}
    @general_stats << {:name => I18n.t('reports.index.general.place_images'), :count => PlaceImage.count}
    @general_stats << {:name => I18n.t('reports.index.general.users'), :count => PlaceEvaluation.user_count}
    
    @venue_stats = []
    venue_categories = VenueCategory.sorted
    if venue_categories.present?
      venue_categories.each do |venue_category|
        x = Hash.new
        @venue_stats << x
        
        x[:id] = venue_category.id
        x[:name] = venue_category.name
        x[:stats] = VenueSummary.stats_overall_place_evaluation_results(venue_category.id, true)
      
      end
    end

    respond_to do |format|
      format.html 
      format.json { render json: @places }
    end
  end
  
  def venues
    @venue_category = VenueCategory.sorted.find(params[:venue_category_id])
    if @venue_category.present?
      venues = Venue.by_category(params[:venue_category_id]).sorted
      if venues.present?
        @disabilities = Disability.is_active.sorted

        venue_ids = venues.map{|x| x.id}.uniq
        place_ids = Place.ids_in_venues(venue_ids)

        @stats = VenueSummary.stats_overall_place_evaluation_results(params[:venue_category_id], true)
#        @places = PlaceSummary.stats_overall_place_evaluation_results
#        @evals = PlaceSummary.stats_overall_evaluation_results

        @general_stats = []
        @general_stats << {:name => I18n.t('reports.index.general.places'), :count => Place.count_with_venues(venue_ids)}
        @general_stats << {:name => I18n.t('reports.index.general.certified'), :count => @stats.present? && @stats.has_key?(:certified) && @stats[:certified].has_key?(:total) ? @stats[:certified][:total][:total] : 0}
        @general_stats << {:name => I18n.t('reports.index.general.public'), :count => @stats.present? && @stats.has_key?(:public) && @stats[:public].has_key?(:total) ? @stats[:public][:total][:total] : 0}
        @general_stats << {:name => I18n.t('reports.index.general.answers'), :count => PlaceEvaluationAnswer.in_places(place_ids).answer_count}
        @general_stats << {:name => I18n.t('reports.index.general.place_images'), :count => PlaceImage.in_places(place_ids).count}
        @general_stats << {:name => I18n.t('reports.index.general.users'), :count => PlaceEvaluation.in_places(place_ids).user_count}

        @venue_stats = []
        if venues.present?
          venues.each do |venue|
            x = Hash.new
            @venue_stats << x
            
            x[:id] = venue.id
            x[:name] = venue.name
            x[:stats] = VenueSummary.stats_overall_place_evaluation_results(venue.id)
          
          end
        end
      end
      respond_to do |format|
        format.html 
        format.json { render json: @places }
      end
    else
			flash[:info] =  t('app.msgs.does_not_exist')
			redirect_to reports_path(:locale => I18n.locale)
			return
    end

  end
  
  
end
