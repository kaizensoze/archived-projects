class LocationsController < ApplicationController
  load_resource except: :index
  authorize_resource
  before_action :load_regions, only: [:new, :edit, :create, :update]
  before_action :load_location_categories, only: [:index, :new, :edit, :create, :update]

  # GET /locations
  def index
    @locations = if params[:longitude] && params[:latitude]
                   search_params = {
                     longitude: params[:longitude],
                     latitude: params[:latitude],
                     radius: params[:radius] || 1
                   }
                   Location.geo_search(search_params).records
                 else
                   []
                 end
    if params[:name_search]
      @locations = Location.where('name ILIKE ?', "%#{params[:name_search]}%")
    end

    respond_to :html, :json
  end

  # GET /locations/1
  def show
    @locations = Location.geo_search(longitude: @location.longitude, latitude: @location.latitude).records
  end

  # GET /locations/new
  def new
  end

  # GET /locations/1/edit
  def edit
  end

  # POST /locations
  def create
    @location.slug = @location.name.downcase.gsub(/[ .]/, "-")

    if @location.save
      redirect_to @location, notice: 'Location was successfully created.'
    else
      render action: 'new'
    end
  end

  # PATCH/PUT /locations/1
  def update
    if @location.update(location_params)
      redirect_to @location, notice: 'Location was successfully updated.'
    else
      render action: 'edit'
    end
  end

  # DELETE /locations/1
  def destroy
    @location.destroy
    redirect_to locations_url, notice: 'Location was successfully destroyed.'
  end

  def like
    @location.likes.build({ agent_id: current_agent.id })

    if @location.save
      render 'like'
    else
      redirect_to (@location), error: "An error stopped you from liking the location. :("
    end

  end

  def unlike
    like = @location.likes.where(agent_id: current_agent.id)

    if like.delete_all
      render 'unlike'
    end
  end

  private

  def load_location_categories
    @location_categories ||= LocationCategory.order(name: :asc)
  end

  def load_regions
    @regions ||= Region.order(name: :asc)
  end

  def location_params
    params.require(:location).permit(:name,
                                     :description,
                                     :latitude,
                                     :longitude,
                                     :address_line_one,
                                     :address_line_two,
                                     :city,
                                     :state,
                                     :zip,
                                     :neighborhood_id,
                                     :website,
                                     :facebook_url,
                                     :delivery_website,
                                     :yelp_url,
                                     :phone_number,
                                     :location_category_id,
                                     :slug,
                                     :featured,
                                     :image,
                                     :cover_image,
                                     :modern
                                     )
  end
end
