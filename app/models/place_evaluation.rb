class PlaceEvaluation < ActiveRecord::Base

  belongs_to :place
  belongs_to :user
  belongs_to :disability
  has_many :place_evaluation_answers, :dependent => :destroy
	has_many :place_evaluation_organizations, :dependent => :destroy
	has_many :place_evaluation_images, :dependent => :destroy
	has_many :organizations, :through => :place_evaluation_organizations
  accepts_nested_attributes_for :place_evaluation_answers
  accepts_nested_attributes_for :place_evaluation_images
  attr_accessible :place_id, :user_id, :place_evaluation_answers_attributes, :place_evaluation_images_attributes, 
                  :created_at, :disability_id, :is_certified, :disability_ids, :organization_ids, :disability_other_text
  attr_accessor :disability_ids

  validates :user_id, :disability_id, :presence => true

  after_create :update_summaries

  ANSWERS = {'no_answer' => 0, 'not_relevant' => 1, 'needs' => 2, 'has_bad' => 3, 'has_good' => 4, 'has' => 5, 'no' => 6, 'yes' => 7}
  SUMMARY_ANSWERS = {'not_accessible' => 0, 'no_answer' => 1, 'not_relevant' => 2}

  # update the summary for this place
  def update_summaries
    if self.is_certified?
      PlaceSummary.update_certified_summaries(self.place_id, self.id)
    else
      PlaceSummary.update_summaries(self.place_id, self.id)
    end
  end
  
  def self.answer_key_name(value)
    ANSWERS.keys[ANSWERS.values.index(value)]
  end
  
  def self.summary_answer_key_name(value)
    SUMMARY_ANSWERS.keys[SUMMARY_ANSWERS.values.index(value)]
  end
  
  def self.with_answers(place_id, options={})
    options[:is_certified] = false if options[:is_certified].nil?

    includes(:place_evaluation_answers)
    .where(:place_id => place_id, :is_certified => options[:is_certified])  
    .where(:disability_id => options[:disability_id]) if options[:disability_id].present?
  end
  
  def self.sorted
    order('place_evaluations.created_at desc, place_evaluations.user_id asc')
  end
  
  # get all of the answers for a place
  # so that a summary can be computed
  # place_id: id of place to get answers for
  # options:
  # - is_certified: get answers that are certified (default = false)
  # - place_evaluation_id: get answers for a specific evaluation
  def self.with_answers_for_summary(place_id, options={})
    options[:is_certified] = false if options[:is_certified].nil?
    
    x = select('place_evaluations.id, place_evaluations.disability_id, place_evaluation_answers.question_pairing_id, place_evaluation_answers.answer')
    .joins(:place_evaluation_answers)
    .where(:place_id => place_id, :is_certified => options[:is_certified])  
    
    x = x.where('place_evaluations.id = ?', options[:place_evaluationd_id]) if options[:place_evaluationd_id].present?
    
    return x
  end



end
