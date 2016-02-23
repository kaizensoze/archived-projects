require 'jsonapi/resource_controller'

class ApiConversationParticipantsController < JSONAPI::ResourceController
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
    class ConversationParticipantsController < ApiConversationParticipantsController
      before_action :verify_token
      before_action :verify_current_user, only: [:update]

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

      def verify_current_user
        if context && context[:current_user]
          if context[:current_user].id != ConversationParticipant.find(request.params[:id]).agent.id
            errors = {
              errors: [{
                title: 'Unauthorized',
                detail: "Unathorized to update conversation participant #{request.params[:id]}."
              }]
            }
            render json: errors, status: :forbidden
          end
        end
      end
    end
  end
end
