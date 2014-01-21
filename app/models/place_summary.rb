class PlaceSummary < ActiveRecord::Base

  belongs_to :place
  
  attr_accessible :place_id, :summary_type, :summary_type_identifier, 
                  :data_type, :data_type_identifier, 
                  :score, :special_flag, :num_answers, :num_evaluations
  validates :place_id, :summary_type, :data_type, :presence => true
  
  SUMMARY_TYPES = {'overall' => 0, 'disability' => 1, 'instance' => 2}
  DATA_TYPES = {'overall' => 0, 'category' => 1}


  # for the given place id, update the summary data
  def self.update_summaries(place_id, place_evaluation_id)
    if place_id.present? && place_evaluation_id.present?

      # get all evaluations for this place
      evaluations = PlaceEvaluations.with_answers(place_id, disability.id).sorted
      
      # compute overall summary
      


      # compute summary for disability this eval belongs to
      
      
      
      # compute summary for this evaluation
    
    end
  end

end
