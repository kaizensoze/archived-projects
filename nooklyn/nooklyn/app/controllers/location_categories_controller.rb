class LocationCategoriesController < ApplicationController
  before_action :set_location_category, only: [:show, :edit, :update]
  load_and_authorize_resource

  # GET /location_categories
  def index
  end

  # GET /location_categories/1
  def show
    @locations = @location_category.locations
  end

  # GET /location_categories/new
  def new
  end

  # GET /location_categories/1/edit
  def edit
  end

  # POST /location_categories
  def create
    if @location_category.save
      redirect_to location_categories_path, notice: 'Location category was successfully created.'
    else
      render action: 'new'
    end
  end

  # PATCH/PUT /location_categories/1
  def update
    if @location_category.update(location_category_params)
      redirect_to @location_category, notice: 'Location category was successfully updated.'
    else
      render action: 'edit'
    end
  end

  # DELETE /location_categories/1
  def destroy
    @location_category.destroy
    redirect_to location_categories_url, notice: 'Location category was successfully destroyed.'
  end

  private

  def set_location_category
    @location_category = LocationCategory.find_by_slug(params[:id]) || LocationCategory.find(params[:id])
  end

  def location_category_params
    params.require(:location_category).permit(:name, :image, :slug)
  end
end
