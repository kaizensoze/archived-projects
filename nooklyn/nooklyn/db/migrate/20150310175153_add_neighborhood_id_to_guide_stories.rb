class AddNeighborhoodIdToGuideStories < ActiveRecord::Migration
  def change
    add_column :guide_stories, :neighborhood_id, :integer
  end
end
