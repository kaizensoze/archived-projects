module Admin
  class ListingsController < BaseController
    layout "nklyn-pages"
    before_filter :load_agents, except: [:show, :search]
    before_filter :load_neighborhoods, except: [:show, :search]

    # GET /listings
    # GET /listings.json
    def index
      @listings = Listing.includes(:neighborhood, :listing_agent, :sales_agent)
                         .page(params[:page])
                         .per(100)
                         .order(updated_at: :desc)
    end

    def available
      @listings = Listing.includes(:neighborhood, :listing_agent, :sales_agent)
                         .available
                         .page(params[:page])
                         .per(100)
                         .order(updated_at: :desc)
      render :index
    end

    def pending
      @listings = Listing.includes(:neighborhood, :listing_agent, :sales_agent)
                         .pending
                         .page(params[:page])
                         .per(100)
                         .order(updated_at: :desc)
      render :index
    end

    def rented
      @listings = Listing.includes(:neighborhood, :listing_agent, :sales_agent)
                         .rented
                         .page(params[:page])
                         .per(100)
                         .order(updated_at: :desc)
      render :index
    end

    def show
      @listing = Listing.includes(:photos, :likes, :interested_agents).find(params[:id])
    end

    def listings_need_updates
      @agents = Agent.non_employees
      @listings = Listing.pending.where({ sales_agent_id: @agents }).includes(:neighborhood, :listing_agent, :sales_agent).page(params[:page]).per(100)
      render :index
    end

    def search
      if params[:q].nil?
        @listings = []
      else
        @listings = Listing.search(params[:q])
      end
    end

    private

    def load_agents
      @agents ||= Agent.employees.order(first_name: :asc)
    end

    def load_neighborhoods
      @neighborhoods ||= Neighborhood.brooklyn_and_queens.order(name: :asc)
    end
  end
end
