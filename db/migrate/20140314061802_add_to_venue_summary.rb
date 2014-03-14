class AddToVenueSummary < ActiveRecord::Migration
  def up
    add_column :venue_summaries, :accessibility_type, :integer
    add_index :venue_summaries, :accessibility_type 

    add_column :place_summaries, :venue_id, :integer
    add_column :place_summaries, :venue_category_id, :integer
    add_index :place_summaries, :venue_id
    add_index :place_summaries, :venue_category_id

    # add values for venue ids
    place_ids = PlaceSummary.select('distinct place_id')
    if place_ids.present?
      PlaceSummary.transaction do 
        place_ids.map{|x| x.place_id}.each do |place_id|
          venue = Place.place_venue_ids(place_id)
          
          if venue.present?
            PlaceSummary.where(:place_id => place_id).update_all(:venue_id => venue[:venue_id], :venue_category_id => venue[:venue_category_id])
          end
        end    
      end
    end    
  end
  
  
  def down
    remove_index :venue_summaries, :accessibility_type 
    remove_column :venue_summaries, :accessibility_type

    remove_index :place_summaries, :venue_id
    remove_index :place_summaries, :venue_category_id
    remove_column :place_summaries, :venue_id
    remove_column :place_summaries, :venue_category_id
  end
end
