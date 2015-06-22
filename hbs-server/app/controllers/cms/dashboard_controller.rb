class Cms::DashboardController < ApplicationController
  before_action :authenticate_admin_user!
  
  layout 'cms'

  def index
  end
end
