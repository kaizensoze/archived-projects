module Matrix
  class OfficesController < MatrixBaseController
    before_action :load_agents
    before_action :load_deposit_statuses, only: [:new, :edit, :create, :update]
    def show
      @office = Office.find(params[:id])
      @deposits = @office.deposits
                         .pending
                         .active_deposits
                         .with_agent(current_agent)
                         .includes(:transactions, :office, :listing_agent, :sales_agent)
                         .order(updated_at: :desc)
    end
    private

      def load_agents
        @agents ||= Agent.employees.order(first_name: :asc)
      end

      def load_deposit_statuses
        @deposit_statuses ||= DepositStatus.order(name: :asc)
      end
  end
end
