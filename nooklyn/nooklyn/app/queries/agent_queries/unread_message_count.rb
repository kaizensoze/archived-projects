module AgentQueries
  class UnreadMessageCount

    def initialize(agent)
      # If there is no logged-in user, we just assign a blank new user
      @agent = agent || Agent.new
    end

    def any_unread?
      count > 0
    end

    def count
      result.count
    end

    private

    def result
      @_result ||= ConversationParticipant.where(agent_id: agent.id)
        .where(unread_messages: true)
    end

    attr_reader :agent
  end
end