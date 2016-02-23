class CreateGuideStories < ActiveRecord::Migration
  def change
    create_table :guide_stories do |t|
      t.integer :guide_id
      t.string :url
      t.string :title
      t.text :description
      t.boolean :featured

      t.timestamps null: false
    end
  end
end
