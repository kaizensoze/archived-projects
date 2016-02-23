module Matrix
  class ListingsController < MatrixBaseController
    authorize_resource
    before_filter :load_neighborhoods
    before_filter :load_regions
    before_filter :load_agents, except: [:my_listings, :manage_photos]

    # GET /listings
    # GET /listings.json
    def index
      authorize! :create, Listing
      @listings = Listing.includes(:neighborhood, :listing_agent, :sales_agent)
                         .page(params[:page])
                         .per(500)
                         .available
                         .order(updated_at: :desc)
    end

    def commercial
      authorize! :create, Listing
      @listings = Listing.includes(:neighborhood, :listing_agent, :sales_agent)
                         .commercial
                         .page(params[:page])
                         .per(500)
                         .available
                         .order(updated_at: :desc)

      render :index
    end

    def my_listings
      @listings = Listing.includes(:neighborhood, :listing_agent, :sales_agent)
                         .where({ sales_agent_id: current_agent.id })
                         .page(params[:page])
                         .per(500)
                         .available
                         .order(updated_at: :desc)
    end

    def pending
      @listings = Listing.includes(:neighborhood, :listing_agent, :sales_agent)
                         .page(params[:page])
                         .per(500)
                         .pending
                         .order(updated_at: :desc)
      render :index
    end

    def sales
      @listings = Listing.includes(:neighborhood, :listing_agent, :sales_agent)
                         .page(params[:page])
                         .per(500)
                         .sales
                         .available
                         .order(updated_at: :desc)
      render :index
    end

    def rented
      @listings = Listing.includes(:neighborhood, :listing_agent, :sales_agent)
                         .page(params[:page])
                         .per(500)
                         .rented
                         .order(updated_at: :desc)

      render :index
    end

    def my_rented
      @listings = Listing.rented
                         .page(params[:page])
                         .per(500)
                         .where({sales_agent_id: current_agent, listing_agent_id: current_agent})
                         .order(updated_at: :desc)
      render :index
    end

    def search
      authorize! :create, Listing
      if params[:q].nil?
        @listings = []
      else
        @listings = Listing.rented.where('address ILIKE ?', "%#{params[:q]}%")
      end
    end

    def change_status
      listing = Listing.find(params[:id])
      status = params[:status]
      command = ListingCommands::ChangeStatus.new(listing, status, current_agent)

      command.on(:success) do
        head :no_content
      end

      command.on(:failure) do
        head :unprocessable_entity
      end

      command.execute
    end

    # Manage Listing Photos Page

    def manage_photos
      @listing = Listing.find(params[:id])
    end

    # Easier to print version of listings

    def table_view
      @listings = Listing.available.includes(:neighborhood, :listing_agent)
    end

    def syndication
      @listings = Listing.available
                         .exclusive
                         .includes(:neighborhood, :listing_agent)
      render :table_view
    end

    private
    def load_regions
      @regions = Region.order(name: :asc)
    end
    def load_neighborhoods
      @neighborhoods = Neighborhood.joins("/*left outer*/ join listings on listings.neighborhood_id = neighborhoods.id and listings.status = 'Available'")
                                   .group("listings.neighborhood_id, neighborhoods.id")
                                   .order("neighborhoods.name asc")
    end

    def load_agents
      @agents ||= Agent.employees.order(first_name: :asc)
    end
  end
end
