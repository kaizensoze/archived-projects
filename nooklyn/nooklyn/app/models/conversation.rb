class Conversation < ActiveRecord::Base

  has_many :messages,
           class_name: 'ConversationMessage',
           dependent: :destroy

  has_many :participants,
           class_name: 'ConversationParticipant',
           dependent: :destroy

  has_many :participating_agents,
           through: :participants,
           source: :agent

  scope :with_agent, ->(agent) { joins(:participants).where(conversation_participants: { agent_id: agent.id }) }

  def archived_for?(agent)
    participant = participants.where(agent: agent).first

    # If we are logged in as a super admin, participant is nil, causing this
    # line to error-out. As a temporary solution, we can just return nil in that
    # situation.
    participant&.archived?
  end
end
