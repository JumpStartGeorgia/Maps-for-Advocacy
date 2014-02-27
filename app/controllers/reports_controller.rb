class ReportsController < ApplicationController

  def index
    @places = PlaceSummary.stats_overall_place_evaluation_results
    @evals = PlaceSummary.stats_overall_evaluation_results
    @disabilities = Disability.is_active.sorted

    respond_to do |format|
      format.html 
      format.json { render json: @places }
    end
  end
  
end
