require 'jsonapi/resource_controller'

class ApiMatesController < JSONAPI::ResourceController
  def context
    api_key = ApiKey.where(token: request.env['HTTP_API_TOKEN']).first
    unless api_key.nil?
      agent = Agent.find(api_key.agent_id)
      {
        current_user: agent
      }
    end
  end
end

class Api::V1::MatesController < ApiMatesController
  before_action :verify_token, only: [:index, :show, :create, :update]
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
      mate = MatePost.find(request.params[:id])
      if mate && context[:current_user].id != mate.agent_id
        errors = {
          errors: [{
            title: 'Unauthorized',
            detail: "Unathorized to update agent #{request.params[:id]}."
          }]
        }
        render json: errors, status: :forbidden
      end
    end
  end
end
