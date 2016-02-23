class ListingMailer < ActionMailer::Base
  default from: "help@nooklyn.com"

  def status_change_notification(listing_change, sendee)
    @change_agent = listing_change.agent
    @listing = listing_change.listing
    @sendee = sendee
    @status = listing_change.humanable_status

    to_address = "#{@sendee.first_name} <#{@sendee.email}>"
    subject = "Listing Status Change: #{@listing.address.truncate(25)}"
    mail(to: to_address, subject: subject)
  end
end
