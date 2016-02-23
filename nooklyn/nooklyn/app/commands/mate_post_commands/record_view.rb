module MatePostCommands
  class RecordView

    def initialize(mate_post, viewing_agent, format, ip_address, user_agent)
      @format = format
      @ip_address = ip_address
      @mate_post = mate_post
      @user_agent = user_agent
      @viewing_agent = viewing_agent
    end

    def execute
      if should_record?
        MatePostView.create!({
          agent: viewing_agent,
          ip_address: ip_address,
          format: format,
          mate_post: mate_post,
          user_agent: user_agent
        })
      end
    end

    private

    def should_record?
      !(viewing_agent.admin? || viewing_agent.super_admin?)
    end

    attr_reader :format, :ip_address, :mate_post, :user_agent, :viewing_agent
  end
end

