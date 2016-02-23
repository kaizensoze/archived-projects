require 'jsonapi/resource_controller'

class ApiMateFavoritesController < JSONAPI::ResourceController
  def context
    agent_id = request.params["agent-id"]
    if agent_id.nil?
      errors = {
        errors: [{
          title: 'agent-id param required',
          detail: 'An agent-id param is required.'
        }]
      }
      render json: errors, status: :forbidden
      return
    end

    requested_agent = Agent.find_by(id: agent_id)
    if requested_agent.nil?
      emptyJSON = {
        data: []
      }
      render json: emptyJSON, status: :success
    else
      {
        requested_user: requested_agent
      }
    end
  end
end

module Api
  module V1
    class MateFavoritesController < ApiMateFavoritesController
    end
  end
end
