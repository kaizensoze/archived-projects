module MessageCommands
  class AddParticipants

    def initialize(conversation, participating_agents)
      @conversation = conversation
      @participating_agents = Array(participating_agents)
    end

    def execute
      agent_ids = current_participants.map(&:agent_id)

      new_agents = participating_agents.reject { |p| agent_ids.include?(p.id) }
        .uniq

      conversation.participating_agents << new_agents
    end

    private

    def current_participants
      conversation.participants
    end

    attr_reader :conversation, :participating_agents
  end
end
