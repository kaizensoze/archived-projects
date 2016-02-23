class ListingsController < ApplicationController
  load_resource except: [:index, :rentals, :sales, :_listings, :show]
  authorize_resource
  before_action :load_liked_listings, only: [:index, :rentals, :sales, :commercial, :_listings]
  layout "full_map", only: :index

  # GET /listings
  # GET /listings.json
  def index
    @listings = if params[:longitude] && params[:latitude]
                  search_params = {
                    longitude: params[:longitude],
                    latitude: params[:latitude],
                    radius: params[:radius] || 1,
                    residential_only: params[:residential_only] || false
                  }
                  Listing.geo_search(search_params).records
                else
                  Listing
                    .available
                    .visible
                    .has_thumbnail
                    .order(featured: :desc, hearts_count: :desc, updated_at: :desc)
                    .to_a
                end

    # check api token [if any] to prevent leaking employee-only data
    api_key = ApiKey.where(token: request.env['HTTP_API_TOKEN']).first
    unless api_key.nil?
      @agent = Agent.find(api_key.agent_id)
    end

    respond_to do |format|
      format.html
      format.json { render "index": {data: {listings: @listings, agent: @agent }}}
    end
  end

  def rentals
    render :index
  end

  def sales
    render :index
  end

  def commercial
    render :index
  end

  # GET /listings/1
  # GET /listings/1.json
  def show
    @listing = Listing.includes(:photos, :likes, :interested_agents).find(params[:id])

    if @listing.private && cannot?(:create, Listing)
      redirect_to listings_path, notice: 'This listing is no longer available'
    else
      @page = Listings::ShowView.new(@listing)

      respond_to do |format|
        format.html
      end
    end
  end


  # GET /listings/new
  # GET /listings/new.json
  def new
    @regions = Region.order(name: :asc)
    @offices = Office.order(name: :asc)
    @agents = Agent.employees.order(first_name: :asc)

    respond_to do |format|
      format.html # new.html.erb
      format.json { render json: @listing }
    end
  end

  # GET /listings/1/edit
  def edit
    @regions = Region.order(name: :asc)
    @offices = Office.order(name: :asc)
    @agents = Agent.employees.order(first_name: :asc)
  end

  # POST /listings
  # POST /listings.json
  def create
    @regions = Region.order(name: :asc)
    @offices = Office.order(name: :asc)
    @agents = Agent.employees.order(first_name: :asc)

    respond_to do |format|
      if @listing.save
        format.html { redirect_to @listing, notice: 'Listing was successfully created.' }
        format.json { render json: @listing, status: :created, location: @listing }
      else
        format.html { render action: "new", notice: "Correct the mistakes below to create the new listing" }
        format.json { render json: @listing.errors, status: :unprocessable_entity }
      end
    end
  end

  # PUT /listings/1
  # PUT /listings/1.json
  def update
    @regions = Region.order(name: :asc)
    @offices = Office.order(name: :asc)
    @agents = Agent.employees.order(first_name: :asc)

    respond_to do |format|
    if @listing.update_attributes(listing_params)
        format.html { redirect_to @listing, notice: 'Listing was successfully updated.' }
        format.json { head :no_content }
      else
        format.html { render action: "edit", notice: "Correct the mistakes below to update the listing" }
        format.json { render json: @listing.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /listings/1
  # DELETE /listings/1.json
  def destroy
    @listing.destroy

    respond_to do |format|
      format.html { redirect_to listings_url }
      format.json { head :no_content }
    end
  end

  # Manage Listing Photos Page
  def manage_photos
    # @listing = Listing.find(params[:id])
  end

  def gallery
    image_size = params[:image_size] || 'original'
    command = ListingCommands::ArchiveGallery.new(@listing, image_size: image_size)

    command.on(:success) do |zip_data|

      # Clean up the filename to make it suitible for file systems
      clean_address = @listing.address
        .downcase
        .gsub(/,/, '')
        .gsub(/ /, '_')
        .gsub(/_united_states/, '')

      filename = "#{clean_address}.zip"

      send_data(zip_data, type: 'application/zip', filename: filename)
    end

    command.on(:failure) do |ex|
      redirect_to manage_photos_listing_path(@listing), notice: 'An error prevented us from zipping up these images :('
    end

    command.execute
  end

  def craigslist
  end

  def like
    @listing.likes.build({ agent_id: current_agent.id })
    if @listing.save
      respond_to do |format|
        format.html { redirect_to @listing }
        format.js { head :ok }
        format.json { head :no_content }
      end
    else
      respond_to do |format|
        format.html { redirect_to @listing, error: 'An error stopped you from liking the listing. :(' }
        format.js { head :unprocessable_entity }
        format.json { head :unprocessable_entity }
      end
    end
  end

  def unlike
    like = @listing.likes.where(agent_id: current_agent.id)
    if like.delete_all
      respond_to do |format|
        format.html { redirect_to @listing }
        format.js { head :ok }
      end
    end
  end

  def _listings
    @listings = Listing
      .available
      .visible
      .has_thumbnail
      .includes(:neighborhood)
      .order(featured: :desc, hearts_count: :desc, updated_at: :desc)
      .to_a
    render :layout => false
  end

  private

  def load_liked_listings
    @liked_listings = current_agent.try(:liked_listings).try(:pluck, :id) || []
  end

  def listing_params
    params.require(:listing)
          .permit(:access,
                  :address,
                  :apartment,
                  :cats_ok,
                  :cross_streets,
                  :dogs_ok,
                  :latitude,
                  :longitude,
                  :amenities,
                  :date_available,
                  :bathrooms,
                  :bedrooms,
                  :description,
                  :fee,
                  :exclusive,
                  :featured,
                  :rental,
                  :residential,
                  :landlord_contact,
                  :listing_agent_id,
                  :sales_agent_id,
                  :neighborhood_id,
                  :pets,
                  :photo,
                  :photo_tag,
                  :primaryphoto,
                  :price,
                  :square_feet,
                  :station,
                  :status,
                  :subway_line,
                  :term,
                  :title,
                  :utilities,
                  :move_in_cost,
                  :owner_pays,
                  :private,
                  :office_id,
                  :full_address,
                  :zip,
                  :convertible,
                  :landlord_llc,
                  :image)
  end

end
