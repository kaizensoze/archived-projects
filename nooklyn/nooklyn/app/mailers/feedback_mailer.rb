class FeedbackMailer < ActionMailer::Base
  default from: "Nooklyn Support Notifier <help@nooklyn.com>"

  def feedback_message(reply_to_email, message, name)
    @message = message
    mail(:to => "help@nooklyn.com", :subject => "New Feedback from #{name}", reply_to: reply_to_email)
  end
end
