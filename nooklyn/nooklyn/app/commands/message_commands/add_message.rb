module MessageCommands
  class AddMessage

    def initialize(new_message, conversation = new_message.conversation)
      @new_message  = new_message
      @conversation = conversation
    end

    def execute
      Conversation.transaction do
        add_message_to_conversation
        mark_conversation_participants_as_unread
        create_message
        send_email_notification
        send_sms_notification
      end

      new_message
    end

    private

    def add_message_to_conversation
      new_message.conversation = conversation
    end

    def email_notifyer
      @_email_notifyer ||= EmailNotificationService.new
    end

    def mark_conversation_participants_as_unread
      conversation.participants.reject { |p| p.agent_id == new_message.agent_id }
        .each { |p| p.unread_messages = true }
        .each { |p| p.archived_at = nil }
        .each { |p| p.save }
    end

    def message_snippet
      new_message.message.slice(0, 70)
    end

    def send_email_notification
      recipients = conversation.participating_agents
        .reject { |a| a.id == new_message.agent_id }
        .select { |a| a.email_notifications? }

      email_notifyer.send_email(sender, new_message.message, recipients) unless recipients.empty?
    end

    def send_sms_notification
      recipients = conversation.participating_agents
        .reject { |a| a.id == new_message.agent_id }
        .select { |a| a.sms_notifications? }
      message = "#{sender.first_name} said: \"#{message_snippet}\" https://nooklyn.com/conversations"

      sms_notifyer.send_sms(message, recipients) unless recipients.empty?
    end

    def sender
      new_message.agent
    end

    def sms_notifyer
      @_sms_notifyer ||= SmsNotificationService.new
    end

    def create_message
      new_message.save
    end

    attr_reader :conversation, :new_message
  end
end
