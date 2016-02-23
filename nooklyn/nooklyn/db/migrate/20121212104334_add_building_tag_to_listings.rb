class AddBuildingTagToListings < ActiveRecord::Migration
  def up
    add_column :listings, :building_tag, :string
  end
  
  def down
    remove_column :listings, :building_tag
  end
end
