class ConversationParticipant < ActiveRecord::Base
  belongs_to :agent
  belongs_to :conversation,
             inverse_of: :messages

  def archived?
    !!archived_at
  end
end
