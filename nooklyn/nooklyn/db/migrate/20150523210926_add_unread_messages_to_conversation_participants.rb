class AddUnreadMessagesToConversationParticipants < ActiveRecord::Migration
  def change
    add_column :conversation_participants, :unread_messages, :boolean, default: false
  end
end
