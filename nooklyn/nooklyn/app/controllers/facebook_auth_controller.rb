class FacebookAuthController < ApplicationController
  def facebook_login
    access_token = facebook_auth_params[:"access-token"]
    access_token_expiration = facebook_auth_params[:"access-token-expiration"]

    begin
      @graph = Koala::Facebook::API.new(access_token)
      fb_user_info = @graph.get_object("me")

      auth = OpenStruct.new({
        provider: "facebook",
        uid: fb_user_info["id"],
        credentials: OpenStruct.new({
          token: access_token,
          expires_at: Time.parse(access_token_expiration).to_i
        }),
        info: OpenStruct.new({
          email: fb_user_info["email"],
          image: "http://graph.facebook.com/#{fb_user_info["id"]}/picture?type=large"
        }),
        extra: OpenStruct.new({
          raw_info: OpenStruct.new({
            first_name: fb_user_info["first_name"],
            last_name: fb_user_info["last_name"],
            gender: fb_user_info["gender"],
            link: fb_user_info["link"]
          })
        })
      })

      @agent = Agent.find_for_facebook_oauth(auth)

      api_key_json = get_api_key_json(@agent.email, "", access_token) # no password for facebook users since they're authenticating with access token
      render json: api_key_json
    rescue
      # force fail (presumably invalid input sent to endpoint)
      api_key_json = get_api_key_json("", "", "")
      render json: api_key_json
    end
  end

  def get_api_key_json(email, password, auth_token)
    api_key = ApiKey.lookup_by_user_credentials(email, password, auth_token)

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

  def facebook_auth_params
    params
      .permit("access-token", "access-token-expiration")
      .symbolize_keys
  end
end
