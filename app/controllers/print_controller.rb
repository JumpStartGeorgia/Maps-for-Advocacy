class PrintController < ApplicationController
#  before_filter :authenticate_user!
#  before_filter do |controller_instance|
#    controller_instance.send(:valid_role?, User::ROLES[:certification])
#  end

  def index
    @venue_categories = VenueCategory.with_venues
    @disabilities = Disability.sorted.is_active_certified
    @questions = {:common => [], :venue => []}
    
    if @disabilities.present?
      @questions[:common] = QuestionCategory.questions_for_venue(disability_ids: @disabilities.map{|x| x.id}, is_certified: true)
      @questions[:venue] = VenueCategory.with_venue_custom_questions(disability_ids: @disabilities.map{|x| x.id}, is_certified: true)
    end

    gon.print_landscape_alert = I18n.t('app.msgs.print_landscape')

    respond_to do |format|
      format.html # index.html.erb
    end
  end


end
