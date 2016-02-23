module Admin
  class LocationsController < BaseController
    layout "nklyn-pages"

    # GET /locations
    def index
      @locations = Location.includes(:location_category)
                            .page(params[:page])
                            .per(150)
                            .order(created_at: :desc)
      if params[:name_search]
        @locations = Location.where('name ILIKE ?', "%#{params[:name_search]}%").page(params[:page]).per(150)
      end
    end

    def modern_layout_locations
      @locations = Location.includes(:location_category)
                            .modern_layout
                            .page(params[:page])
                            .per(150)
                            .order(created_at: :desc)

      render :index
    end

    # GET /locations/1
    def show
      @location = Location.find(params[:id])
      @locations = Location.geo_search(longitude: @location.longitude, latitude: @location.latitude).records
    end

    def make_feature
      @location = Location.find(params[:id])
      @location.featured = true
      @location.save(:validate => false)
      respond_to do |format|
        format.html { redirect_to admin_locations_path, notice: 'This location is now featured.' }
      end
    end

    def remove_feature
      @location = Location.find(params[:id])
      @location.featured = false
      @location.save(:validate => false)
      respond_to do |format|
        format.html { redirect_to admin_locations_path, notice: 'This location is no longer featured.' }
      end
    end

  end
end
