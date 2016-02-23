module Matrix
  class MatrixBaseController < ApplicationController
    before_action :verify_employee

    private

    def verify_employee
      unless current_agent.try(:employee?)
        raise CanCan::AccessDenied
      end
    end
  end
end
