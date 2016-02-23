class ApplicationController < ActionController::Base
  protect_from_forgery
  before_filter :configure_permitted_parameters, if: :devise_controller?

  helper_method :unread_messages

	rescue_from CanCan::AccessDenied do |exception|
		redirect_to root_url, alert: exception.message
	end

  def unread_messages
    @unread_messages ||= AgentQueries::UnreadMessageCount.new(current_agent)
  end

  def current_ability
   @current_ability ||= Ability.new(current_agent)
  end


  protected

  def after_sign_in_path_for(agent)
    listings_path
  end

  def configure_permitted_parameters
    devise_parameter_sanitizer.for(:sign_up) << :first_name
    devise_parameter_sanitizer.for(:sign_up) << :last_name
    devise_parameter_sanitizer.for(:sign_up) << :phone
    devise_parameter_sanitizer.for(:sign_up) << :facebook_url
    devise_parameter_sanitizer.for(:sign_up) << :image
    devise_parameter_sanitizer.for(:sign_up) << :provider
    devise_parameter_sanitizer.for(:sign_up) << :email
    devise_parameter_sanitizer.for(:sign_up) << :gender
    devise_parameter_sanitizer.for(:sign_up) << :uid
    devise_parameter_sanitizer.for(:sign_up) << :oauth_expires_at
    devise_parameter_sanitizer.for(:sign_up) << :oauth_token
    devise_parameter_sanitizer.for(:sign_up) << :slug
    devise_parameter_sanitizer.for(:account_update) << :email_notifications
    devise_parameter_sanitizer.for(:account_update) << :first_name
    devise_parameter_sanitizer.for(:account_update) << :last_name
    devise_parameter_sanitizer.for(:account_update) << :phone
    devise_parameter_sanitizer.for(:account_update) << :facebook_url
    devise_parameter_sanitizer.for(:account_update) << :image
    devise_parameter_sanitizer.for(:account_update) << :provider
    devise_parameter_sanitizer.for(:account_update) << :gender
    devise_parameter_sanitizer.for(:account_update) << :uid
    devise_parameter_sanitizer.for(:account_update) << :oauth_expires_at
    devise_parameter_sanitizer.for(:account_update) << :oauth_token
    devise_parameter_sanitizer.for(:account_update) << :profile_picture
    devise_parameter_sanitizer.for(:account_update) << :private_profile
    devise_parameter_sanitizer.for(:account_update) << :sms_notifications
    devise_parameter_sanitizer.for(:account_update) << :slug
  end

end
