class MessageMailer < ActionMailer::Base
  default from: "Nooklyn Message Notification <donotreply@nooklyn.com>"

  def new_message_notification(sender, recipient, message)
    @sender = sender
    @recipient = recipient
    @message = message

    mail(to: "#{@recipient.first_name} <#{@recipient.email}>", subject: "#{@sender.first_name} sent you a message!")
  end
end
