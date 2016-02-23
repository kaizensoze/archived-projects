class RenameSalesToDeals < ActiveRecord::Migration
  def change
    rename_table :sales, :deals
  end
end
