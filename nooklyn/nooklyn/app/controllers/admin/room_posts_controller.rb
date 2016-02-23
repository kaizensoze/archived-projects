module Admin
  class RoomPostsController < BaseController
    layout "nklyn-pages"

    def index
      @room_posts = RoomPost.includes(:neighborhood, :interested_agents, :agent)
                    .page(params[:page])
                    .per(100)
                    .order(created_at: :asc)
    end

    def make_private
      @room_post = RoomPost.find(params[:id])
      @room_post.hidden = true
      @room_post.save(:validate => false)
      respond_to do |format|
        format.html { redirect_to admin_room_posts_path, notice: 'Your post is now private.' }
      end
    end

    def make_public
      @room_post = RoomPost.find(params[:id])
      @room_post.hidden = false
      @room_post.save(:validate => false)
      respond_to do |format|
        format.html { redirect_to admin_room_posts_path, notice: 'Your post is now public.' }
      end
    end
  end
end
