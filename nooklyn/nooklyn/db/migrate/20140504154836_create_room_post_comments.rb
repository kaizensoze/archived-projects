class CreateRoomPostComments < ActiveRecord::Migration
  def change
    create_table :room_post_comments do |t|
      t.string :name
      t.string :email
      t.string :phone
      t.string :ip_address
      t.string :user_agent
      t.integer :agent_id
      t.integer :room_post_id
      t.text :message

      t.timestamps
    end
  end
end
