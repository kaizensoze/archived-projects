class AgentsController < ApplicationController
  authorize_resource

  def index

    @agents_by_deposit = Agent.employees
      .not_on_probation
      .has_profile_picture
      .is_not_super_admin
      .joins(:deposit_stats)
      .merge(AgentDepositStat.current_month.ranked)

    respond_to do |format|
      format.html # index.html.erb
      format.json { render json: @agents }
    end
  end

  def show
    @agent = Agent.find_by_slug(params[:id]) || Agent.find(params[:id])

    if @agent.private_profile? && !current_agent&.super_admin?
      redirect_to root_path, notice: "That user has a private profile"
    else
      @mate_posts = @agent.liked_mates.order(:when)
      @room_posts = @agent.liked_rooms

      respond_to do |format|
        format.html
        format.json { render json: @agent }
      end
    end
  end

  def mates
    @agent = Agent.find_by_slug(params[:id]) || Agent.find(params[:id])
    @mates = @agent.liked_mates
  end

  def rm_favorites
    @mate_posts = current_agent.liked_mates
    @room_posts = current_agent.liked_rooms
  end

  def rm_settings
    @mate_post = current_agent.mate_posts.order("created_at").last
    @room_post = current_agent.room_posts.order("created_at").last
    @regions ||= Region.order(name: :asc)
  end

  def rm_leads
  end

  def my_collections
  end
end
