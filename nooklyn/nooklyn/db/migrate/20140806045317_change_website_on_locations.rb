class ChangeWebsiteOnLocations < ActiveRecord::Migration
  def change
    change_column :locations, :website, :string
  end
end
