class CreateGuideStoryPhotos < ActiveRecord::Migration
  def change
    create_table :guide_story_photos do |t|
      t.string :caption
      t.integer :agent_id
      t.integer :guide_story_id

      t.timestamps null: false
    end
  end
end
