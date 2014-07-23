class PlaceEvaluationOrganization < ActiveRecord::Base
	belongs_to :place_evaluation
	belongs_to :organization
end
