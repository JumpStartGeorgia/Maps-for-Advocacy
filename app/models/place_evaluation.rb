class PlaceEvaluation < ActiveRecord::Base

  belongs_to :place
  belongs_to :user
  belongs_to :disability
  has_many :place_evaluation_answers, :dependent => :destroy
  accepts_nested_attributes_for :place_evaluation_answers
  attr_accessible :place_id, :user_id, :place_evaluation_answers_attributes, :created_at, :disability_id
  validates :user_id, :disability_id, :presence => true

  after_create :update_summaries

  ANSWERS = {'no_answer' => 0, 'not_relevant' => 1, 'needs' => 2, 'has_bad' => 3, 'has_good' => 4, 'has' => 5}
  SUMMARY_ANSWERS = {'not_accessible' => 0, 'no_answer' => 1, 'not_relevant' => 2}

  # update the summary for this place
  def update_summaries
    PlaceSummary.update_summaries(self.place_id, self.id)
  end
  
  def self.answer_key_name(value)
    ANSWERS.keys[ANSWERS.values.index(value)]
  end
  
  def self.summary_answer_key_name(value)
    SUMMARY_ANSWERS.keys[SUMMARY_ANSWERS.values.index(value)]
  end
  
  def self.with_answers(place_id, disability_id=nil)
    includes(:place_evaluation_answers)
    .where(:place_id => place_id)  
    .where(:disability_id => disability_id) if disability_id.present?
  end
  
  def self.sorted
    order('place_evaluations.created_at desc, place_evaluations.user_id asc')
  end
  
  # get all of the answers for a place
  # so that a summary can be computed
  def self.with_answers_for_summary(place_id)
    select('place_evaluations.id, place_evaluations.disability_id, place_evaluation_answers.question_pairing_id, place_evaluation_answers.answer')
    .joins(:place_evaluation_answers)
    .where(:place_id => place_id)  
  end



end
