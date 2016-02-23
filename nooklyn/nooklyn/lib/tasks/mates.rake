namespace :mates do
  desc 'Sends emails to users with mate profiles about to expire'
  task notify_recent_expiry: :environment do
    Rails.logger.info "Mailer Method #{ActionMailer::Base.delivery_method}"
    MatePost.recently_expired
      .includes(:agent)
      .each { |mp| MatePostMailer.about_to_expire(mp).deliver_later }
  end
end
