class PrintController < ApplicationController

  def index
    @venue_categories = VenueCategory.with_venues

    @disabilities = Disability.sorted.is_active
    public_disabilities = @disabilities.select{|x| x.active_public == true}
    cert_disabilities = @disabilities.select{|x| x.active_certified == true}

    # get public info
    @public_questions = {:common => [], :venue => []}
    
    if public_disabilities.present?
      @public_questions[:common] = QuestionCategory.questions_for_venue(disability_ids: public_disabilities.map{|x| x.id}, is_certified: false)
      @public_questions[:venue] = VenueCategory.with_venue_custom_questions(disability_ids: public_disabilities.map{|x| x.id}, is_certified: false)
    end


    # if the user can submit certified evals, get the info on certified evals
    @show_certified = false
    if user_signed_in? && current_user.role?(User::ROLES[:certification])
      @show_certified = true

      @cert_questions = {:common => [], :venue => []}
      
      if cert_disabilities.present?
        @cert_questions[:common] = QuestionCategory.questions_for_venue(disability_ids: cert_disabilities.map{|x| x.id}, is_certified: true)
        @cert_questions[:venue] = VenueCategory.with_venue_custom_questions(disability_ids: cert_disabilities.map{|x| x.id}, is_certified: true)
      end
    end

    gon.print_landscape_alert = I18n.t('app.msgs.print_landscape')

    respond_to do |format|
      format.html # index.html.erb
    end
  end


end
