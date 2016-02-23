require 'houston'

APN = Houston::Client.production
APN.certificate = File.read("#{Rails.root}/config/apns/nooklyn_apns_prod.pem")

class ConversationMessage < ActiveRecord::Base
  belongs_to :agent

  belongs_to :conversation,
             inverse_of: :messages

  validates :ip_address,
            presence: true

  validates :message,
            presence: true

  validates :user_agent,
            presence: true

  after_save :send_push_notification,
    if: Proc.new { |cm| Rails.env.production? || ['1', 'true', 'TRUE'].include?(ENV['DEBUG_PUSH_NOTIFICATION']) }

  after_save do
      conversation.update_attribute(:updated_at, Time.current) unless conversation.nil?
  end

  def attachments
    ConversationMessageAttachment.extract(message)
  end

  private

  def send_push_notification
    conversation_id = self.conversation_id

    if self.conversation_id.nil?
      return
    end

    conversation = Conversation.find(conversation_id)
    participants = conversation.participants

    senderId = self.agent_id
    sender = Agent.find(senderId)

    alert_msg = "#{sender.name}: #{self.message}"

    participants.each do |participant|
      device_token = participant.agent.device_token
      if device_token.present? && participant.agent.id != senderId
        notification = Houston::Notification.new(device: device_token)
        notification.alert = alert_msg
        notification.badge = 1
        notification.sound = "sosumi.aiff"

        APN.push(notification)
      end
    end
  end
end
