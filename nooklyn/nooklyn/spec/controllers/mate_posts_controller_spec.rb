describe MatePostsController, type: :controller do
  context "when agent is facebook authenticated" do
    before :each do
      @agent = create(:agent, provider: "facebook")
      sign_in_as(@agent)
    end

    it "displays index" do
      get :index

      expect(response).to render_template :index
    end

    describe "liking and unliking" do
      before :each do
        @post = create(:mate_post)
      end

      it "can like mate posts" do
        xhr :get, :like, id: @post.id, format: :js

        expect(@post.likes.where(agent_id: @agent.id)).not_to be_empty
      end

      it "can unlike posts" do
        create(:mate_post_like, mate_post: @post, agent: @agent)
        xhr :get, :unlike, id: @post.id, format: :js

        expect(@post.likes.where(agent_id: @agent.id)).to be_empty
      end
    end

    describe "updating posts" do
      before :each do
        @post = create(:mate_post, agent: @agent)
      end

      it "makes agent's own posts private" do
        get :make_private, id: @post.id
        @post.reload

        expect(@post.hidden).to eq true
        expect(response).to redirect_to rm_settings_path
      end

      it "makes agent's own posts public" do
        @post.update(hidden: true)
        get :make_public, id: @post.id
        @post.reload

        expect(@post.hidden).to eq false
        expect(response).to redirect_to rm_settings_path
      end

      it "updates agent's own post" do
        put :update, id: @post.id, mate_post: @post.attributes.merge(price: 1100)
        @post.reload

        expect(@post.price).to eq 1100
        expect(response).to redirect_to rm_settings_path
      end

      it "does not allow changes to another agent's post" do
        @post.update(agent: create(:agent))
        put :update, id: @post.id, mate_post: @post.attributes.merge(price: 1100)
        @post.reload

        expect(@post.price).to eq 950
        expect(response).to redirect_to root_path
      end
    end
  end

  context "when agent is not facebook authenticated" do
    before :each do
      sign_in_as(create(:agent))
    end

    it "renders facebook message instead of index" do
      get :index

      expect(response).to render_template 'facebook_message'
    end

    it "renders facebook message instead of new" do
      get :new

      expect(response).to render_template 'facebook_message'
    end
  end

  context "when agent is not signed in" do
    it "renders facebook message instead of index" do
      get :index

      expect(response).to render_template 'facebook_message'
    end
  end
end
