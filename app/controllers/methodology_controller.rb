class MethodologyController < ApplicationController

  def index
    respond_to do |format|
      format.html # index.html.erb
    end
  end

  def questions
    @disabilities = Disability.sorted.is_active

    @questions = {:certified => {:common => [], :venue => []}, :public => {:common => [], :venue => []}}

    @questions[:certified][:common] = QuestionCategory.questions_for_venue(disability_ids: @disabilities.map{|x| x.id}, is_certified: true)
    @questions[:certified][:venue] = VenueCategory.with_venue_custom_questions(disability_ids: @disabilities.map{|x| x.id}, is_certified: true)


    @questions[:public][:common] = QuestionCategory.questions_for_venue(disability_ids: @disabilities.map{|x| x.id}, is_certified: false)
    @questions[:public][:venue] = VenueCategory.with_venue_custom_questions(disability_ids: @disabilities.map{|x| x.id}, is_certified: false)

    respond_to do |format|
      format.html # index.html.erb
    end
  end
  
  def venues
    @venues = VenueCategory.with_venues()
    respond_to do |format|
      format.html # index.html.erb
    end
  end

  
  def calculations
    respond_to do |format|
      format.html # index.html.erb
    end
  end


end
