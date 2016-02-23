class RenameColumn < ActiveRecord::Migration
  def self.up
    rename_column :mate_post_likes, :room_post_id, :mate_post_id
  end

  def self.down
    # rename back if you need or do something else or do nothing
  end
end
