module MessageCommands
  class UnarchiveConversation

    def initialize(conversation, unarchiving_agents)
      @conversation = conversation
      @unarchiving_agents = Array(unarchiving_agents)
      @subscribers = Hash.new { |h, k| h[k] = [] }
    end

    def execute
      agent_ids = unarchiving_agents.map(&:id)

      ConversationParticipant.transaction do
        current_participants.select { |p| agent_ids.include?(p.agent_id) }
          .each { |p| p.archived_at = nil }
          .each { |p| p.save! }
      end

      run_callbacks(:success)
    rescue
      run_callbacks(:failure)
    end

    def on(event, &callback)
      subscribers[event] << callback
    end

    private

    def current_participants
      conversation.participants
    end

    def run_callbacks(event, *args)
      subscribers[event].each { |callback| callback.call(*args) }
    end

    attr_reader :conversation, :unarchiving_agents, :subscribers
  end
end
