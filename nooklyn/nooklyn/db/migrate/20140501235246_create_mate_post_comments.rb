class CreateMatePostComments < ActiveRecord::Migration
  def change
    create_table :mate_post_comments do |t|
      t.string :name
      t.string :email
      t.string :phone
      t.string :ip_address
      t.string :user_agent
      t.integer :agent_id
      t.integer :mate_post_id

      t.timestamps
    end
  end
end
