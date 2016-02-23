class AddHiddenToMatePosts < ActiveRecord::Migration
  def change
    add_column :mate_posts, :hidden, :boolean, :default => false
  end
end
