class NeighborhoodsController < ApplicationController
  authorize_resource except: :mates
  before_action :load_liked_listings, only: [:show]
  before_action :load_regions, only: [:new, :edit, :create, :update]

  # GET /neighborhoods
  # GET /neighborhoods.json
  def index
    @neighborhoods = Neighborhood.visible.order(name: :asc)
    @locations = Location.modern_layout.featured
    respond_to do |format|
      format.html # index.html.erb
      format.json { render json: @neighborhoods }
    end
  end

  def all
    @neighborhoods = Neighborhood.all
    render :index
  end

  # GET /neighborhoods/1
  # GET /neighborhoods/1.json
  def show
    @neighborhood = Neighborhood.find_by_slug(params[:id]) || Neighborhood.find(params[:id])
    @listings = @neighborhood.listings.available.visible.order(featured: :desc, updated_at: :desc)
    @locations = @neighborhood.locations

    respond_to do |format|
      format.html # show.html.erb
      format.json { render json: @neighborhood }
    end
  end

  # GET /neighborhoods/new
  # GET /neighborhoods/new.json
  def new
    @neighborhood = Neighborhood.new

    respond_to do |format|
      format.html # new.html.erb
      format.json { render json: @neighborhood }
    end
  end

  def mates
    if current_agent.try(:provider?) || current_agent.try(:super_admin?)
      @neighborhood = Neighborhood.find_by_slug(params[:id]) || Neighborhood.find(params[:id])
      @neighborhoods = Neighborhood.visible.order(name: :asc)
      @mate_posts = @neighborhood.mate_posts.visible.upcoming.order(when: :asc)
      render :mates
    else
      render 'mate_posts/facebook_message'
    end
  end

  def rooms
    @neighborhood = Neighborhood.find_by_slug(params[:id]) || Neighborhood.find(params[:id])
    @neighborhoods = Neighborhood.visible.order(name: :asc)
    @room_posts = @neighborhood.room_posts.visible.upcoming.order(when: :asc)
    render :rooms
  end

  def locations
    @neighborhood = Neighborhood.find_by_slug(params[:id]) || Neighborhood.find(params[:id])
    @locations = @neighborhood.locations.order(featured: :desc, modern: :desc, updated_at: :desc)
    render :locations
  end

  def _listings
    @listings = Neighborhood.find(params[:id])
      .listings
      .available
      .visible
      .has_thumbnail
      .order(featured: :desc, hearts_count: :desc, updated_at: :desc)
      .to_a
    render :layout => false
  end

  # GET /neighborhoods/1/edit
  def edit
    @neighborhood = Neighborhood.find_by_slug(params[:id]) || Neighborhood.find(params[:id])
  end

  # POST /neighborhoods
  # POST /neighborhoods.json
  def create
     @neighborhood = Neighborhood.new(neighborhood_params)
     formatted_hood_name = @neighborhood.name.downcase.strip.gsub(/[^a-z0-9\s]/i, '').gsub(/\s/i, '-')
     formatted_region_name = @neighborhood.region.name.downcase.strip.gsub(/[^a-z0-9\s]/i, '').gsub(/\s/i, '-')
     @neighborhood.slug = "#{formatted_hood_name}-#{formatted_region_name}"

    respond_to do |format|
      if @neighborhood.save
        format.html { redirect_to neighborhoods_path, notice: 'Neighborhood was successfully created.' }
        format.json { render json: @neighborhood, status: :created, location: @neighborhood }
      else
        format.html { render action: "new" }
        format.json { render json: @neighborhood.errors, status: :unprocessable_entity }
      end
    end
  end

  # PUT /neighborhoods/1
  # PUT /neighborhoods/1.json
  def update
    @neighborhood = Neighborhood.find_by_slug(params[:id]) || Neighborhood.find(params[:id])

    respond_to do |format|
      if @neighborhood.update_attributes(neighborhood_params)
        format.html { redirect_to @neighborhood, notice: 'Neighborhood was successfully updated.' }
        format.json { head :no_content }
      else
        format.html { render action: "edit" }
        format.json { render json: @neighborhood.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /neighborhoods/1
  # DELETE /neighborhoods/1.json
  def destroy
    @neighborhood = Neighborhood.find_by_slug(params[:id]) || Neighborhood.find(params[:id])
    @neighborhood.destroy

    respond_to do |format|
      format.html { redirect_to neighborhoods_url }
      format.json { head :no_content }
    end
  end

  private

  def load_liked_listings
    @liked_listings ||= current_agent.try(:liked_listings).try(:pluck, :id) || []
  end

  def neighborhood_params
    params.require(:neighborhood).permit(:borough, :name, :image, :featured, :region_id, :latitude, :longitude)
  end

  def load_regions
    @regions ||= Region.order(name: :asc)
  end
end
