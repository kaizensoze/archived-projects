module ListingCommands
  class ChangeStatus

    def initialize(listing, status, agent)
      @agent = agent
      @change_record = :command_not_executed
      @listing = listing
      @status = status
      @subscribers = Hash.new { |h, k| h[k] = [] }
    end

    def execute
      update_listing_and_create_audit_log
      send_confirmation_email_to_acting_agent
      send_notification_email_to_listing_agent

      run_callbacks(:success)
    rescue
      run_callbacks(:failure)
    end

    def on(event, &callback)
      subscribers[event] << callback
    end

    private

    def update_listing_and_create_audit_log
      Listing.transaction do
        @change_record = ListingStatusChange.create!({
          agent: agent,
          listing: listing,
          status: status
        })
        listing.update!(status: change_record.humanable_status)
      end
    end

    def run_callbacks(event, *args)
      subscribers[event].each { |callback| callback.call(*args) }
    end

    def send_confirmation_email_to_acting_agent
      send_notification_email(agent)
    end

    def send_notification_email_to_listing_agent
      send_notification_email(listing.listing_agent)
    end

    def send_notification_email(sendee)
      ListingMailer.status_change_notification(change_record, sendee)
        .deliver_later
    end

    attr_reader :agent, :change_record, :listing, :status, :subscribers
  end
end
