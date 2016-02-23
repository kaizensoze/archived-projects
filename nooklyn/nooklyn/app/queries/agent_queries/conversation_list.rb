module AgentQueries
  class ConversationList

    def initialize(agent, filters = nil)
      filters = Hash(filters)

      @agent = agent
      @unread_filter = filters.fetch(:unread) { :all }
      @archived_filter = filters.fetch(:archived) { :all }
    end

    def list
      result
    end

    private

    def result
      @_result ||= Conversation.with_agent(agent)
        .select('conversations.*', 'conversation_participants.unread_messages AS unread')
        .includes(:messages)
        .merge(filter_scopes)
        .order(updated_at: :desc)
    end

    def filter_scopes
      filter = Conversation.all

      if unread_filter != :all
        filter = filter.merge(unread_filter_scope)
      end

      if archived_filter != :all
        filter = filter.merge(archived_filter_scope)
      end

      filter
    end

    def unread_filter_scope
      Conversation.joins(:participants)
        .where(conversation_participants: { unread_messages: unread_filter })
    end

    def archived_filter_scope
      if archived_filter == true
        Conversation.joins(:participants)
          .where.not(conversation_participants: { archived_at: nil })
      else
        Conversation.joins(:participants)
          .where(conversation_participants: { archived_at: nil })
      end
    end

    attr_reader :agent, :archived_filter, :unread_filter
  end
end
