module Matrix
  class NeighborhoodsController < MatrixBaseController
    before_filter :load_regions
    def show
      @neighborhood = Neighborhood.find_by_slug(params[:id])
      @neighborhoods = Neighborhood.brooklyn_and_queens.order(name: :asc)
      @listings = @neighborhood.listings
                               .available
                               .page(params[:page])
                               .per(500)
                               .order(featured: :desc, updated_at: :desc)
      @agents = Agent.employees.order('created_at ASC')
    end

    def rented
      @neighborhood = Neighborhood.find_by_slug(params[:id])
      @neighborhoods = Neighborhood.brooklyn_and_queens.order(name: :asc)
      @listings = @neighborhood.listings
                               .rented
                               .page(params[:page])
                               .per(500)
                               .order(featured: :desc, updated_at: :desc)
      @agents = Agent.employees.order('created_at ASC')
      render :show
    end

    private

    def load_regions
      @regions = Region.order(name: :asc)
    end
  end
end
