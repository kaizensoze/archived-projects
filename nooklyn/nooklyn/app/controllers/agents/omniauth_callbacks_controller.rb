class Agents::OmniauthCallbacksController < Devise::OmniauthCallbacksController
  def facebook
    @agent = Agent.find_for_facebook_oauth(request.env["omniauth.auth"])

    if @agent.persisted?
      sign_in_and_redirect @agent, :event => :authentication
      set_flash_message(:notice, :success, :kind => "Facebook") if is_navigational_format?
    else
      session["devise.facebook_data"] = request.env["omniauth.auth"]
      redirect_to new_agent_registration_url
    end
  end
end
