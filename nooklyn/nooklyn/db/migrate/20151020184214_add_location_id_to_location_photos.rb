class AddLocationIdToLocationPhotos < ActiveRecord::Migration
  def change
    add_column :location_photos, :location_id, :integer
  end
end
