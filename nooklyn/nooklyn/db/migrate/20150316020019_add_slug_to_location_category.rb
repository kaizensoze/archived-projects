class AddSlugToLocationCategory < ActiveRecord::Migration
  def change
    add_column :location_categories, :slug, :string
  end
end
