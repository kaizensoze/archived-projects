class SmsNotificationService

  SENDER_NUMBER = "+13478366665"

  def send_sms(message, recipients)
    recipient_numbers = recipients.map { |r| r.phone }
      .map { |p| SmsNotificationService.format_phone_number(p) }
      .reject { |p| p == :invalid_number }

    recipient_numbers.each do |number|
      begin
        twilio_client.messages.create(
          from: SENDER_NUMBER,
          to: number,
          body: message,
        )
      rescue Twilio::REST::RequestError => e
        # We should probably send an error notification here eventually.
        # If we run this in a background job, we can just remove this to see
        # the types of errors we receive.
      end
    end
  end

  private

  def twilio_client
    @_twilio_client ||= if account_sid.nil? || auth_token.nil?
                          NullTwilioClient.new
                        else
                          Twilio::REST::Client.new account_sid, auth_token
                        end
  end

  def account_sid
    Rails.application.secrets.twilio_account_sid
  end

  def auth_token
    Rails.application.secrets.twilio_auth_token
  end

  def self.format_phone_number(dirty_number)

    dirty_number = String(dirty_number)
    clean_number = dirty_number.gsub(/\D/, '')

    if clean_number.size == 10
      "+1#{clean_number}"
    elsif ( clean_number.size == 11 && clean_number.start_with?('1') )
      "+{clean_number}"
    else
      :invalid_number
    end
  end

  class NullTwilioClient
    def method_missing(method_name, *args, &block)
      self
    end

    def create(from:, to:, body:)
      Rails.logger.debug <<-LOG
        SMS Message Log
        ---------------
        From: #{from}
        To: #{to}
        Message:
        #{body}
      LOG

      self
    end
  end
end
