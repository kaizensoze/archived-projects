require 'jsonapi/resource_controller'

class ApiListingIgnoresController < JSONAPI::ResourceController
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
    class ListingIgnoresController < ApiListingIgnoresController
      before_action :verify_token

      private

      def verify_token
        unless ApiKey.where(token: request.env['HTTP_API_TOKEN']).first
          errors = {
            errors: [{
              title: 'Invalid API Token',
              detail: 'A valid API Token must be passed in as a request header \'API-TOKEN: <some-token-here>\''
            }]
          }
          render json: errors, status: :forbidden
        end
      end
    end
  end
end
