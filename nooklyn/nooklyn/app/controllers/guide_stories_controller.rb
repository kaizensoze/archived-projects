class GuideStoriesController < ApplicationController
  load_and_authorize_resource
  before_action :load_regions, except: [:index, :show, :destroy]
  before_action :load_guides, only: [:new, :edit]

  def index
  end

  def show
  end

  def new
  end

  def edit
  end

  def create
    if @guide_story.save
      redirect_to guide_path(@guide_story.guide), notice: 'Story was successfully created.'
    else
      render action: 'new'
    end
  end

  def update
    @guide_story.update(guide_story_params)
    render action: 'show'
  end

  def destroy
    @guide_story.destroy
    redirect_to guide_path(@guide_story.guide), notice: "Story was successfully deleted."
  end

  private

  def load_guides
    @guides = Guide.order(created_at: :asc)
  end

  def load_regions
    @regions = Region.order(name: :asc)
  end

  def guide_story_params
    params.require(:guide_story).permit(:guide_id, :url, :title, :description, :featured, :image, :neighborhood_id)
  end
end
