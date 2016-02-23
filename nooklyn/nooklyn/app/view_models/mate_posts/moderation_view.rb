module MatePosts
  class ModerationView

    attr_reader :mate_post

    def initialize(mate_post)
      @mate_post = mate_post
    end

    def conversations
      Conversation.select('conversations.*, COUNT(conversation_messages.id) AS messages_count')
        .includes(:participating_agents)
        .joins(:messages)
        .where(context_url: mate_post_url)
        .group('conversations.id')
        .order('messages_count DESC')
    end

    def mate_agent
      mate_post.agent
    end

    private

    def mate_post_url
      "https://nooklyn.com/mate_posts/#{mate_post.id}"
    end

  end
end
