module Admin
  class MatePostsController < BaseController
    layout "nklyn-pages"

    # GET /mate_posts
    def index
      @mate_posts = MatePost.includes(:neighborhood, :interested_agents, :agent)
                    .page(params[:page])
                    .per(100)
                    .order(created_at: :asc)
    end

    def make_feature
      @mate_post = MatePost.find(params[:id])
      @mate_post.featured = true
      @mate_post.save(:validate => false)
      respond_to do |format|
        format.html { redirect_to admin_mate_posts_path, notice: 'Your post is now featured.' }
      end
    end

    def make_private
      @mate_post = MatePost.find(params[:id])
      @mate_post.hidden = true
      @mate_post.save(:validate => false)
      respond_to do |format|
        format.html { redirect_to admin_mate_posts_path, notice: 'Your post is now private.' }
      end
    end

    def make_public
      @mate_post = MatePost.find(params[:id])
      @mate_post.hidden = false
      @mate_post.save(:validate => false)
      respond_to do |format|
        format.html { redirect_to admin_mate_posts_path, notice: 'Your post is now public.' }
      end
    end
  end
end
