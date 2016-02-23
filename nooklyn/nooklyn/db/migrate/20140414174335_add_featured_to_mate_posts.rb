class AddFeaturedToMatePosts < ActiveRecord::Migration
  def change
    add_column :mate_posts, :featured, :boolean, :default => false
  end
end
