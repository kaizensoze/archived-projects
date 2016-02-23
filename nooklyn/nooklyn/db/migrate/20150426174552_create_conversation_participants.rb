class CreateConversationParticipants < ActiveRecord::Migration
  def change
    create_table :conversation_participants do |t|
      t.references :agent, index: true
      t.references :conversation, index: true

      t.timestamps null: false
    end
    add_foreign_key :conversation_participants, :agents
    add_foreign_key :conversation_participants, :conversations
  end
end
