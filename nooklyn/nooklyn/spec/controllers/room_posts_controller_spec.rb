describe RoomPostsController, type: :controller do
  context "when agent is not signed in" do
    it "displays all room posts" do
      get :index

      expect(response).to render_template :index
    end

    it "displays a particular room post" do
      room_post = create(:room_post)
      get :show, id: room_post.id

      expect(response).to render_template :show
      expect(assigns(:room_post)).to eq room_post
    end

    it "does not display form to create a new post" do
      get :new

      expect(response).to redirect_to root_path
    end
  end

  context "when agent is signed in" do
    before :each do
      @agent = create(:agent, employee: false)
      sign_in_as(@agent)
    end

    it "displays form to create a new post" do
      get :new

      expect(assigns(:regions)).not_to be_nil
      expect(response).to render_template :new
    end

    it "creates a post" do
      rp = build(:room_post, agent_id: nil, description: "Best room ever")
      post :create, room_post: rp.attributes.merge(image: fixture_file_upload("photo.jpg", "image/jpg"))

      expect(assigns(:room_post).agent_id).to eq @agent.id
      expect(RoomPost.find_by(description: "Best room ever")).not_to be_nil
      expect(response).to redirect_to rm_settings_path
    end

    describe "likes" do
      before :each do
        @rp = create(:room_post)
      end

      it "can like a post" do
        xhr :get, :like, id: @rp.id, format: :js

        expect(assigns(:room_post)).to eq @rp
        expect(@rp.interested_agents).to include @agent
      end

      it "can unlike a post" do
        create(:room_post_like, room_post: @rp, agent: @agent)
        xhr :get, :unlike, id: @rp.id, format: :js

        expect(@rp.interested_agents).not_to include @agent
      end
    end

    describe "managing posts" do
      before :each do
        @rp = create(:room_post, agent: @agent)
      end

      it "displays form to edit a post" do
        get :edit, id: @rp

        expect(response).to render_template :edit
      end

      it "updates a post" do
        put :update, id: @rp.id, room_post: @rp.attributes.merge(description: "Not a room.")

        @rp.reload
        expect(response).to redirect_to rm_settings_path
        expect(@rp.description).to eq "Not a room."
      end

      it "makes a post private" do
        get :make_private, id: @rp.id

        @rp.reload
        expect(response).to redirect_to rm_settings_path
        expect(@rp.hidden).to eq true
      end

      it "makes a post public" do
        @rp.update(hidden: true)
        get :make_public, id: @rp.id

        @rp.reload
        expect(response).to redirect_to rm_settings_path
        expect(@rp.hidden).to eq false
      end

      it "cannot edit another agent's post" do
        agent2 = create(:agent)
        @rp.update(agent_id: agent2.id)
        get :edit, id: @rp.id

        expect(response).to redirect_to root_path
      end

      it "cannot destroy a post" do
        delete :destroy, id: @rp

        expect(response).to redirect_to root_path
      end
    end
  end

  context "when agent is a super admin" do
    it "destroys a post" do
      sign_in_as(create(:agent, super_admin: true))
      rp = create(:room_post)
      delete :destroy, id: rp.id

      expect(response).to redirect_to room_posts_url
      expect(RoomPost.find_by(id: rp.id)).to be_nil
    end
  end
end
