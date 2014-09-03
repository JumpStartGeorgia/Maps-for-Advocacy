class PlaceEvaluationImage < ActiveRecord::Base
 
  belongs_to :place_evaluation
  belongs_to :question_pairing
  belongs_to :place_image

  attr_accessible :place_evaluation_id, :question_pairing_id, :place_image_id
  attr_accessor :images
  
end
