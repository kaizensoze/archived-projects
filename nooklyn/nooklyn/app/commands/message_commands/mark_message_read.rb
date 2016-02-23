module MessageCommands
  class MarkMessageRead

    def initialize(conversation, agent)
      @conversation = conversation
      @agent        = agent
    end

    def execute
      Conversation.transaction do
        mark_participant_messages_read
      end
    end

    private

    def mark_participant_messages_read
      conversation.participants
        .where(agent_id: agent.id)
        .update_all(unread_messages: false)
    end

    attr_reader :agent, :conversation
  end
end