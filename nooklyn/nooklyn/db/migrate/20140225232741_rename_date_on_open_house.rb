class RenameDateOnOpenHouse < ActiveRecord::Migration
  def self.up
    rename_column :open_houses, :date, :day
  end

  def self.down
    # rename back if you need or do something else or do nothing
  end
end
