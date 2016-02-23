class AddFeaturedToLocations < ActiveRecord::Migration
  def change
    add_column :locations, :featured, :boolean, :default => false
  end
end
