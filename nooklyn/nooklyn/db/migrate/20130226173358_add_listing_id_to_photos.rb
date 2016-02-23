class AddListingIdToPhotos < ActiveRecord::Migration
  def change
    add_column :photos, :listing_id, :integer
  end
end
