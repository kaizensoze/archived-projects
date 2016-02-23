module Admin
  class NeighborhoodsController < BaseController
    layout "nklyn-pages"

    def index
      @neighborhoods = Neighborhood
                      .page(params[:page])
                      .per(100)
                      .order(name: :asc)
    end
  end
end
