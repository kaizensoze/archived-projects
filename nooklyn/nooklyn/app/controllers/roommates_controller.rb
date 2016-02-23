class RoommatesController < ApplicationController
  before_action :redirect_to_mates
  def index
  end

  def featured
    @mates = MatePost.all
    @rooms = RoomPost.all
  end

  def redirect_to_mates
    if current_agent.try(:provider?)
      redirect_to mates_path
    end
  end
end
