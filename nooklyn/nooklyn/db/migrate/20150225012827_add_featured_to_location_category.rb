class AddFeaturedToLocationCategory < ActiveRecord::Migration
  def change
    add_column :location_categories, :featured, :boolean, :default => false
  end
end
