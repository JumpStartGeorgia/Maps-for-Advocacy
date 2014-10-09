class TitlecasePlaceNames < ActiveRecord::Migration
  def up

    PlaceTranslation.transaction do
      PlaceTranslation.where(:locale => 'en').each do |place|
        place.name = place.name.titlecase
        place.save
      end
    end

  end

  def down
    # do nothing
  end
end
