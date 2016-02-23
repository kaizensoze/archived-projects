class CheckRequestMailer < ActionMailer::Base
  default from: "Diana Bartosik <dianab@nooklyn.com>"

  def check_approved_notification(agent, name, apartment_address, amount)
    @agent = agent
    @send_to_email = @agent.email
    @check_payable_to = name
    @apartment_address = apartment_address
    @amount = amount
    mail(:to => "#{agent.first_name} <#{agent.email}>", :subject => "Your Check is Ready")
  end

  def check_rejected_notification(agent, name, apartment_address, amount)
    @agent = agent
    @send_to_email = @agent.email
    @check_payable_to = name
    @apartment_address = apartment_address
    @amount = amount
    mail(:to => "#{agent.first_name} <#{agent.email}>", :subject => "Your check requested was not approved")
  end
end
