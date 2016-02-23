module Matrix
  class RegionsController < MatrixBaseController
    before_action :load_agents
    def show
      authorize! :create, Listing
      @region = Region.find(params[:id])
      @neighborhoods = @region.neighborhoods.joins("/*left outer*/ join listings on listings.neighborhood_id = neighborhoods.id and listings.status = 'Available'")
                                   .group("listings.neighborhood_id, neighborhoods.id")
                                   .order("neighborhoods.name asc")
      @regions = Region.order(name: :asc)
      @listings = @region.listings.includes(:neighborhood, :listing_agent, :sales_agent)
                         .page(params[:page])
                         .per(500)
                         .available
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
