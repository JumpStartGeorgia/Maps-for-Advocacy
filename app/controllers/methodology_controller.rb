class MethodologyController < ApplicationController

  def index
    respond_to do |format|
      format.html # index.html.erb
    end
  end

  def questions
    # get the disabilities
    @disabilities = Disability.sorted.is_active
    disabilities_public = @disabilities.select{|x| x.active_public == true}
    disabilities_certified = @disabilities.select{|x| x.active_certified == true}

    @questions = {:certified => {:common => [], :venue => []}, :public => {:common => [], :venue => []}}

    if disabilities_certified
      @questions[:certified][:common] = QuestionCategory.questions_for_venue(disability_ids: disabilities_certified.map{|x| x.id}, is_certified: true)
      @questions[:certified][:venue] = VenueCategory.with_venue_custom_questions(disability_ids: disabilities_certified.map{|x| x.id}, is_certified: true)
    end

    if disabilities_public
      @questions[:public][:common] = QuestionCategory.questions_for_venue(disability_ids: disabilities_public.map{|x| x.id}, is_certified: false)
      @questions[:public][:venue] = VenueCategory.with_venue_custom_questions(disability_ids: disabilities_public.map{|x| x.id}, is_certified: false)
    end
    
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
