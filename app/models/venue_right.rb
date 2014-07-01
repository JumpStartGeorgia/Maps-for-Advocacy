class VenueRight < ActiveRecord::Base
  belongs_to :venue
  belongs_to :right

  attr_accessible :venue_id, :right_id

  validates :venue_id, :right_id, :presence => true

end
