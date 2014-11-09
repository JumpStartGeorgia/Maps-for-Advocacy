class PlaceImgSmallStyle < ActiveRecord::Migration
  def up
    PlaceImage.all.each do |img|
      img.image.reprocess! if img.image.exists?
    end
  end

  def down
    PlaceImage.all.each do |img|
      img.image.reprocess! if img.image.exists?
    end
  end
end
