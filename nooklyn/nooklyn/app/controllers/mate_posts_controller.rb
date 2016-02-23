class MatePostsController < ApplicationController
  load_resource except: [:index, :create, :nudge]
  before_action :check_for_provider
  authorize_resource
  before_action :load_regions, only: [:new, :edit, :create, :update]

  # GET /mate_posts
  def index
    @mate_posts = MatePost.includes(:interested_agents, :agent)
                  .includes(neighborhood: :region)
                  .visible
                  .upcoming
                  .order(when: :asc)
    @neighborhoods = Neighborhood.visible.nyc.order(name: :asc)
  end

  def all
    @mate_posts = MatePost.includes(:interested_agents, :agent)
                  .includes(neighborhood: :region)
                  .order(when: :asc)
    @neighborhoods = Neighborhood.visible.order(name: :asc)
    render :index
  end

  def like
    @mate_post.likes.build({ agent_id: current_agent.id })

    if @mate_post.save
      render 'like'
    else
      redirect_to (@mate_post), error: "An error stopped you from liking the listing. :("
    end

  end

  def unlike
    like = @mate_post.likes.where(agent_id: current_agent.id)

    if like.delete_all
      render 'unlike'
    end
  end

  def nudge
    mate_posts = MatePost.where(id: params[:mate_post_ids])
    mate_posts.each do |mate_post|
      RecordMatePostViewJob.perform_later(mate_post, current_agent, 'card', request.remote_ip, request.env["HTTP_USER_AGENT"])
    end

    render json: { result: 'success' }
  end

  # GET /mate_posts/1
  def show
    @moderation_view = MatePosts::ModerationView.new(@mate_post)
    @conversation = Conversation.where(context_url: request.original_url)
      .with_agent(current_agent)
      .select('conversations.*', 'conversation_participants.unread_messages AS unread')
      .order(updated_at: :desc)
      .first
    @conversation ||= Conversation.new

    if agent_signed_in?
      RecordMatePostViewJob.perform_later(@mate_post, current_agent, 'post', request.remote_ip, request.env["HTTP_USER_AGENT"])
    end
  end

  # GET /mate_posts/new
  def new
  end

  # GET /mate_posts/1/edit
  def edit
  end

  # POST /mate_posts
  def create
    post_params = mate_post_params.merge({
      :ip_address => request.remote_ip,
      :user_agent => request.env["HTTP_USER_AGENT"],
      :agent_id => current_agent.id
    })

    @mate_post = MatePost.new(post_params)

    if @mate_post.save
      if params[:alt_from].empty?
        redirect_to rm_settings_path, notice: 'Mate post was successfully created.'
      else
        url = Base64.urlsafe_decode64(params[:alt_from])
        redirect_to url, notice: 'Mate post was successfully created.'
      end
    else
      render action: 'new'
    end
  end

  # PATCH/PUT /mate_posts/1
  def update
    if @mate_post.update(mate_post_params)
      redirect_to rm_settings_path, notice: 'Mate post was successfully updated.'
    else
      render action: 'edit'
    end
  end

  # DELETE /mate_posts/1
  def destroy
    @mate_post.destroy
    redirect_to mate_posts_url, notice: 'Mate post was successfully destroyed.'
  end

  def make_public
    @mate_post.hidden = false
    @mate_post.save
    respond_to do |format|
      format.html { redirect_to mate_post_path(@mate_post), notice: 'Your post is now public.' }
    end
  end

  def make_private
    @mate_post.hidden = true
    @mate_post.save
    respond_to do |format|
      format.html { redirect_to mate_post_path(@mate_post), notice: 'Your post is now private.' }
    end
  end

  private

  def check_for_provider
    if !current_agent.try(:provider?) && !current_agent.try(:super_admin?)
      render 'facebook_message'
    end
  end

  def encoded_page_url
    Base64.urlsafe_encode64(request.original_url)
  end

  helper_method :encoded_page_url

  def load_regions
    @regions ||= Region.order(name: :asc)
  end

  def mate_post_params
    params.require(:mate_post).permit(:description, :price, :cats, :dogs, :neighborhood_id, :when, :image, :hidden, :email)
  end
end
