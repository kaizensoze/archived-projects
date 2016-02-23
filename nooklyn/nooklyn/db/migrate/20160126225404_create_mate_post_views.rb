class CreateMatePostViews < ActiveRecord::Migration
  def change
    create_table :mate_post_views do |t|
      t.references :agent, index: true, foreign_key: true
      t.references :mate_post, index: true, foreign_key: true
      t.string :ip_address
      t.string :user_agent

      t.timestamps null: false
    end
  end
end
