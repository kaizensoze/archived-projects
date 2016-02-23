class AddCaptionToLocationPhotos < ActiveRecord::Migration
  def change
    add_column :location_photos, :caption, :text
  end
end
