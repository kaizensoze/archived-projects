class CreateConversationMessages < ActiveRecord::Migration
  def change
    create_table :conversation_messages do |t|
      t.references :agent, index: true
      t.references :conversation, index: true
      t.string :ip_address
      t.string :user_agent
      t.text :message

      t.timestamps null: false
    end
    add_foreign_key :conversation_messages, :agents
    add_foreign_key :conversation_messages, :conversations
  end
end
