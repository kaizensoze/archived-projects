class JobApplicationMailer < ActionMailer::Base
  default from: "Nooklyn Job Application Notifier <help@nooklyn.com>"

  def job_application_message(reply_to_email, message, name, position)
    @name = name
    @message = message
    @position = position
    mail(:to => ["help@nooklyn.com"], :subject => "New Job Application from #{name}")
  end
end
