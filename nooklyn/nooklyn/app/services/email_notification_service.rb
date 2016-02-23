class EmailNotificationService

  EMAIL_REGEX = /\A[\w+\-.]+@[a-z\d\-]+(\.[a-z]+)*\.[a-z]+\z/i

  def send_email(sender, message, recipients)
    recipients = recipients.reject do |recipient|
      EmailNotificationService.format_email(recipient.email) == :invalid_email
    end

    recipients.each do |recipient|
      MessageMailer.new_message_notification(sender, recipient, message)
        .deliver_later
    end
  end

  private

  def self.format_email(dirty_email)

    email = String(dirty_email)

    if email !~ EMAIL_REGEX
      email = :invalid_email
    end

    email
  end
end
