class ApiKey < ActiveRecord::Base
  belongs_to :agent

  before_create :generate_token

  def self.lookup_by_user_credentials(email, password, oauth_token=nil)
    agent = Agent.find_by(email: email)
    if agent.nil?
      return false
    end

    # try password
    if agent.try(:valid_password?, password)
      return ApiKey.find_or_create_by(agent_id: agent.id)
    end

    # try auth token
    if agent.provider.present?
      if !oauth_token.nil? && agent.oauth_token == oauth_token
        return ApiKey.find_or_create_by(agent_id: agent.id)
      end
    end

    return false
  end

  private

  def generate_token
    loop do
      self.token = SecureRandom.uuid.gsub(/-/, '')
      break unless ApiKey.where(token: self.token).first
    end
  end
end
