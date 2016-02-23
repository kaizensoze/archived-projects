class CreateMatePostIgnores < ActiveRecord::Migration
  def change
    create_table :mate_post_ignores do |t|
      t.integer :agent_id
      t.integer :mate_post_id

      t.timestamps
    end
  end
end
