class RecordMatePostViewJob < ActiveJob::Base
  queue_as :low

  def perform(mate_post, viewing_agent, format, ip_address, user_agent)
    command = MatePostCommands::RecordView.new(mate_post, viewing_agent, format, ip_address, user_agent)
    command.execute
  end
end
