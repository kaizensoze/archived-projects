class GuidesController < ApplicationController
  authorize_resource
  before_action :load_regions, except: [:index, :show, :destroy]

  def index
    @guides = Guide.all
  end

  def show
    @guide = Guide.find_by_slug(params[:id]) || Guide.find(params[:id])
    @neighborhood = @guide.neighborhood
    @location_categories = LocationCategory.order(name: :asc)
    @mates = @neighborhood.mate_posts.upcoming.visible.limit(15).order("RANDOM()")
    @photos = @neighborhood.photos
  end

  def new
    @guide = Guide.new
  end

  def edit
    @guide = Guide.find_by_slug(params[:id]) || Guide.find(params[:id])
  end

  def create
    @guide = Guide.new(guide_params)
    @guide.slug = @guide.neighborhood.name.downcase.gsub(" ", "-")
    @guide.save
    respond_to do |format|
      if @guide.save
        format.html { redirect_to guides_path, notice: 'Guide was successfully created.' }
        format.json { render json: @guide, status: :created, location: @neighborhood }
      else
        format.html { render action: "new" }
        format.json { render json: @guide.errors, status: :unprocessable_entity }
      end
    end
  end

  def update
    @guide = Guide.find_by_slug(params[:id]) || Guide.find(params[:id])
    @guide.update(guide_params)
    respond_to do |format|
      if @guide.save
        format.html { redirect_to guide_path(@guide), notice: 'Guide was successfully updated.' }
        format.json { render json: @guide, status: :created, location: @neighborhood }
      else
        format.html { render action: "new" }
        format.json { render json: @guide.errors, status: :unprocessable_entity }
      end
    end
  end

  def destroy
    @guide = Guide.find_by_slug(params[:id]) || Guide.find(params[:id])
    @guide.destroy
    render :index
  end

  private

  def load_regions
    @regions ||= Region.order(name: :asc)
  end

  def guide_params
    params.require(:guide).permit(:neighborhood_id, :title, :description, :pull_quote, :pull_quote_author, :cover_image, :slug)
  end
end
