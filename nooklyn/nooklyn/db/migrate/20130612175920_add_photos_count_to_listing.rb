class AddPhotosCountToListing < ActiveRecord::Migration
  def change
    add_column :listings, :photos_count, :integer, :default => 0
  end
end
