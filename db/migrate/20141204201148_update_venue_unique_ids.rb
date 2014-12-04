class UpdateVenueUniqueIds < ActiveRecord::Migration
  require 'csv'
  def up
    orig_locale = I18n.locale
    I18n.locale = :en

    # unique ids are missing, so add them
    VenueCategory.transaction do
      rows = CSV.read("#{Rails.root}/db/spreadsheets/Accessibility Upload - Venues.csv", headers: true)
      if rows.present?

        puts "updating categories"
        categories = rows.map{|x| [x[0], x[1]]}.uniq
        puts "csv categories = #{categories}"
        # get all categories on record
        venue_categories = VenueCategory.with_translations(I18n.locale)

        puts "db categories = #{venue_categories.map{|x| x.name}}"

        # look up each category by english name and then add unique id
        categories.each do |category|
          puts "- updating category #{category[1]}"
          match = venue_categories.select{|x| x.name == category[1]}.first
          if match.blank?
            puts "!!!! Category #{category[1]} could not be found in the database"
            raise ActiveRecord::Rollback
          end

          # save the unique id
          match.unique_id = category[0]
          match.save
        end

        puts "db categories now = #{venue_categories.map{|x| [x.name, x.unique_id]}}"

        puts "updating venues"
        venues = Venue.with_translations(I18n.locale)
        rows.each_with_index do |venue, index|
          puts "- updating venue #{venue[5]}, cat uid = #{venue[0]}; uid = #{venue[4]}"
          vc = venue_categories.select{|x| x.unique_id.to_s == venue[0]}.first
          if vc.blank?
            puts "!!!! Row #{index+1} Category #{venue[1]} could not be found in the database when adding venue record"
            raise ActiveRecord::Rollback
          end

          match = venues.select{|x| x.name.downcase == venue[5].downcase && x.venue_category_id == vc.id}.first
          if match.blank?
            puts "!!!! Row #{index+1} Venue #{venue[5]} could not be found in the database"
            raise ActiveRecord::Rollback
          end

          # save the unique id
          match.unique_id = venue[4]
          match.save
        end
      end
    end

    I18n.locale = orig_locale
  end

  def down
    VenueCategory.update_all(:unique_id => nil)
    Venue.update_all(:unique_id => nil)
  end
end
