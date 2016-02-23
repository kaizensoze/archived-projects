module ConversationHelper
  def native_attachments(attachments)
    attachments.map { |a| a.native_type }
  end

  def other_participants_than(conversation, agent)
    conversation.participating_agents.reject { |pa| pa == agent }
  end
end
