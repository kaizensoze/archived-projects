require 'jsonapi/resource_controller'

class ApiListingsController < JSONAPI::ResourceController
  def context
    api_key = ApiKey.where(token: request.env['HTTP_API_TOKEN']).first
    unless api_key.nil?
      agent = Agent.find(api_key.agent_id)
      { current_user: agent }
    end
  end
end

module Api
  module V1
    class ListingsController < ApiListingsController
    end
  end
end
