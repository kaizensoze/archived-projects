class RemoveListingIdFromPhotos < ActiveRecord::Migration
  def up
    remove_column :photos, :listing_id
  end

  def down
    add_column :photos, :listing_id, :integer
  end
end
