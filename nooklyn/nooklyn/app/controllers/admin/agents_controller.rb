module Admin
  class AgentsController < BaseController
    layout "nklyn-pages"

    def index
      @agents = Agent.page(params[:page]).per(100).order(created_at: :asc)

      respond_to do |format|
        format.html # index.html.erb
        format.json { render json: @agents }
      end
    end

    def employees
      @agents = Agent.employees.page(params[:page]).per(100).order(created_at: :asc)
      render :index
    end

    def show
      @agent = Agent.find_by_slug(params[:id]) || Agent.find(params[:id])
      @favorite_mate_posts = @agent.liked_mates
      @favorite_room_posts = @agent.liked_rooms
      @sales_agent_listings = Listing.includes(:neighborhood, :listing_agent, :sales_agent)
                         .where(sales_agent_id: @agent.id)
                         .order(updated_at: :desc)
      @listing_agent_listings = Listing.includes(:neighborhood, :listing_agent, :sales_agent)
                         .where(listing_agent_id: @agent.id)
                         .order(updated_at: :desc)
    end

    def search
      if params[:q].nil?
        @agents = []
      else
        @agents = Agent.search(params[:q])
      end
    end
  end
end
