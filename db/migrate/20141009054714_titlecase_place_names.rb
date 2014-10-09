class TitlecasePlaceNames < ActiveRecord::Migration
  def up

    PlaceTranslation.transaction do
      PlaceTranslation.where(:locale => 'en').each do |place|
        place.name.titlecase
        place.name_will_change!
        place.save
      end
    end

  end

  def down
    # do nothing
  end
end
