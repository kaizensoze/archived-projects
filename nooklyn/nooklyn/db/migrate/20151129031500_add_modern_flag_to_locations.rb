class AddModernFlagToLocations < ActiveRecord::Migration
  def change
    add_column :locations, :modern, :boolean, default: false
  end
end
