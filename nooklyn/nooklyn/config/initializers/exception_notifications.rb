if Rails.env.production?
  Nooklyn::Application.config.middleware.use ExceptionNotification::Rack,
    :email => {
      :email_prefix => "[Nooklyn Alert] ",
      :sender_address => %{"Notifier" <errors@nooklyn.com>},
      :exception_recipients => %w{exceptions@nooklyn.com}
    },
    :slack => {
      :webhook_url => "https://hooks.slack.com/services/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",
      :additional_parameters => {
        :mrkdwn => true
      }
    }
end
