module Admin
  class BaseController < ApplicationController
    before_action :verify_admin

    private

    def verify_admin
      unless current_agent.try(:super_admin?)
        raise CanCan::AccessDenied
      end
    end
  end
end
