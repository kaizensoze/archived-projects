class AddLevelToMatePostViews < ActiveRecord::Migration
  def change
    add_column :mate_post_views, :format, :integer, default: 0
  end
end
