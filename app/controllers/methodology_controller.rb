class MethodologyController < ApplicationController

  def index
    respond_to do |format|
      format.html # index.html.erb
    end
  end

  def questions
    @disabilities = Disability.sorted.is_active
    @common_questions = QuestionCategory.questions_for_venue(disability_ids: @disabilities.map{|x| x.id})
    @venue_questions = VenueCategory.with_venue_custom_questions(disability_ids: @disabilities.map{|x| x.id})

    respond_to do |format|
      format.html # index.html.erb
    end
  end

end
