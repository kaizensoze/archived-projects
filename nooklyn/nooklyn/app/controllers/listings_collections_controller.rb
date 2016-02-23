class ListingsCollectionsController < ApplicationController
  load_resource
  authorize_resource
  skip_load_resource only: :show
  before_action :load_liked_listings, only: :show

  def show
    @listings_collection = ListingsCollection.friendly.find(params[:id])
    @listings = @listings_collection.listings
  end

  def new
    if params[:listing_id]
      @listing = Listing.find(params[:listing_id])
    end
  end

  def create
    @listings_collection.agent = current_agent

    respond_to do |format|
      if @listings_collection.save
        format.html { redirect_to @listings_collection, notice: 'Collection was successfully created.' }
        format.json { render json: @listings_collection, status: :created }
      else
        format.html { render action: "new", notice: "Correct the mistakes below to create the new collection" }
        format.json { render json: @listings_collection.errors, status: :unprocessable_entity }
      end
    end
  end

  def edit
    @listings = @listings_collection.listings
  end

  def update
    respond_to do |format|
      if @listings_collection.update_attributes(listings_collection_params)
        format.html { redirect_to @listings_collection, notice: 'Collection was successfully updated.' }
        format.json { render json: @listings_collection }
      else
        format.html { render action: "edit", notice: "Correct the mistakes below to update the collection" }
        format.json { render json: @listings_collection.errors, status: :unprocessable_entity }
      end
    end
  end

  def add_listing
    listing = Listing.find(params[:listing_id])
    membership = ListingsCollectionMembership.new(listing: listing, listings_collection: @listings_collection)

    respond_to do |format|
      if membership.save
        format.html { redirect_to @listings_collection, notice: 'Listing added to your collection.' }
        format.json { render json: @listings_collection }
      else
        format.html { render action: "edit", notice: "Correct the mistakes below to update the collection" }
        format.json { render json: @listings_collection.errors, status: :unprocessable_entity }
      end
    end
  end

  def remove_listing
    membership = ListingsCollectionMembership.find_by(listing_id: params[:listing_id], listings_collection: @listings_collection)

    respond_to do |format|
      if membership.destroy
        format.html { render nothing: true }
        format.json { head :no_content }
      else
        format.html { render action: "edit", notice: "Correct the mistakes below to update the collection" }
        format.json { head :no_content }
      end
    end
  end

  def make_private
    respond_to do |format|
      if @listings_collection.update_attributes(private: true)
        format.html { redirect_to my_collections_path(current_agent), notice: 'Collection is now private.' }
        format.json { render json: @listings_collection }
      else
        format.html { render action: "edit", notice: "Correct the mistakes below to update the collection" }
        format.json { render json: @listings_collection.errors, status: :unprocessable_entity }
      end
    end

  end

  def make_public
    respond_to do |format|
      if @listings_collection.update_attributes(private: false)
        format.html { redirect_to my_collections_path(current_agent), notice: 'Collection is now public.' }
        format.json { render json: @listings_collection }
      else
        format.html { render action: "edit", notice: "Correct the mistakes below to update the collection" }
        format.json { render json: @listings_collection.errors, status: :unprocessable_entity }
      end
    end

  end

  private

  def load_liked_listings
    @liked_listings = current_agent.try(:liked_listings).try(:pluck, :id) || []
  end

  def listings_collection_params
    params.require(:listings_collection).permit(:id, :name, :description, :agent_id, :private, listing_ids: []).merge(slug: nil)
  end
end
