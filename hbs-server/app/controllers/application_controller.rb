class ApplicationController < ActionController::Base
  # Prevent CSRF attacks by raising an exception.
  # For APIs, you may want to use :null_session instead.
  protect_from_forgery with: :exception

  # htaccess protect non-admin pages
  if ENV['USE_HTTP_AUTH'] == 'true'
    before_action :http_basic_authenticate
  end

  def http_basic_authenticate
    authenticate_or_request_with_http_basic do |name, password|
      name == 'dev' && password == 'devpass'
    end
  end

  def non_activeadmin_controller?
    request.fullpath !~ /^\/admin/
  end
end
