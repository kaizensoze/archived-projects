require 'jsonapi/resource_controller'

class Api::V1::SessionsController < ActionController::Base

  def create
    api_key_json = get_api_key_json(session_params[:email], session_params[:password])
    render json: api_key_json
  end

  def get_api_key_json(email, password)
    api_key = ApiKey.lookup_by_user_credentials(email, password)

    json_hash = if api_key
      {
        session: {
          id: api_key.token,
          links: {
            agent: api_key.agent_id
          }
        }
      }
    else
      {
        errors: [{
          title: 'Invalid User Credentials',
          detail: 'The supplied email and/or password are not correct.'
        }]
      }
    end

    return json_hash
  end

  private

  def session_params
    params.require(:session)
      .permit(:email, :password)
      .symbolize_keys
  end
end
