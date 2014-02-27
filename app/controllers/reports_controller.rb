class ReportsController < ApplicationController

  def index
    @places = PlaceSummary.stats_overall_place_evaluation_results
    @evals = PlaceSummary.stats_overall_evaluation_results
    @disabilities = Disability.is_active.sorted
    @general_stats = []
    @general_stats << {:name => I18n.t('reports.index.general.places'), :count => Place.count}
    @general_stats << {:name => I18n.t('reports.index.general.certified'), :count => @evals.present? ? @evals[:certified][:total][:total] : 0}
    @general_stats << {:name => I18n.t('reports.index.general.public'), :count => @evals.present? ? @evals[:public][:total][:total] : 0}
    @general_stats << {:name => I18n.t('reports.index.general.answers'), :count => PlaceEvaluationAnswer.answer_count}
    @general_stats << {:name => I18n.t('reports.index.general.place_images'), :count => PlaceImage.count}
    @general_stats << {:name => I18n.t('reports.index.general.users'), :count => PlaceEvaluation.user_count}
    

    respond_to do |format|
      format.html 
      format.json { render json: @places }
    end
  end
  
end
