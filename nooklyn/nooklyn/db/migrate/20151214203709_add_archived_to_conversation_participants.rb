class AddArchivedToConversationParticipants < ActiveRecord::Migration
  def change
    add_column :conversation_participants, :archived_at, :datetime
  end
end
