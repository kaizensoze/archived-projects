class RoomPostsController < ApplicationController
  load_and_authorize_resource
  skip_load_resource only: [:index, :create]
  before_action :load_regions, only: [:new, :edit, :create, :update]
  before_action :check_for_provider

  # GET /room_posts
  def index
    @room_posts = RoomPost.includes(:neighborhood, :interested_agents, :agent)
                  .visible
                  .upcoming
                  .order(when: :asc)
  end

  def like
    @room_post.likes.build(agent_id: current_agent.id)

    if @room_post.save
      render 'like'
    else
      redirect_to (@room_post), error: "An error stopped you from liking the listing. :("
    end
  end

  def unlike
    like = @room_post.likes.where(agent_id: current_agent.id)

    if like.delete_all
      render 'unlike'
    end
  end

  def make_private
    @room_post.hidden = true
    @room_post.save
    respond_to do |format|
      format.html { redirect_to rm_settings_path, notice: 'Your post is now private.' }
    end
  end

  def make_public
    @room_post.hidden = false
    @room_post.save
    respond_to do |format|
      format.html { redirect_to rm_settings_path, notice: 'Your post is now public.' }
    end
  end

  # GET /room_posts/1
  def show
  end

  # GET /room_posts/new
  def new
  end

  # GET /room_posts/1/edit
  def edit
  end

  # POST /room_posts
  def create
    rooms_params = room_post_params.merge({
      ip_address: request.remote_ip,
      user_agent: request.env["HTTP_USER_AGENT"],
      agent_id: current_agent.id
    })
    @room_post = RoomPost.new(rooms_params)

    if @room_post.save
      redirect_to rm_settings_path, notice: 'You have successfully added your room!'
    else
      render action: 'new'
    end
  end

  # PATCH/PUT /room_posts/1
  def update
    if @room_post.update(room_post_params)
      redirect_to rm_settings_path, notice: 'You successfully updated your room.'
    else
      render action: 'edit'
    end
  end

  # DELETE /room_posts/1
  def destroy
    @room_post.destroy
    redirect_to room_posts_url, notice: 'Room post was successfully destroyed.'
  end

  private

  def check_for_provider
    if !current_agent.try(:provider?) && !current_agent.try(:super_admin?)
      render 'facebook_message'
    end
  end

  def load_regions
    @regions = Region.order(name: :asc)
  end

  def room_post_params
    params.require(:room_post).permit(:description, :price, :cats, :dogs, :neighborhood_id, :agent_id, :when, :image, :hidden, :featured, :latitude, :longitude, :email, :full_address)
  end
end
