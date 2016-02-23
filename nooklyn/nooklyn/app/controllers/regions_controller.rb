class RegionsController < ApplicationController
  load_and_authorize_resource
  layout "nklyn-pages"
  respond_to :html

  def index
    respond_with(@regions)
  end

  def show
    @neighborhoods = @region.neighborhoods
    @locations = @region.locations.order(featured: :desc, updated_at: :desc)
    respond_with(@region)
  end

  def new
    respond_with(@region)
  end

  def edit
  end

  def create
    @region.save
    respond_with(@region)
  end

  def update
    @region.update(region_params)
    respond_with(@region)
  end

  def destroy
    @region.destroy
    respond_with(@region)
  end

  private

  def region_params
    params.require(:region).permit(:name, :featured, :image, :latitude, :longitude)
  end
end
