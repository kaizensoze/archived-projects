describe NeighborhoodsController, type: :controller do
  context "any agent" do
    describe "before action" do
      describe "#load_liked_listings" do
        before :each do
          @hood = create(:neighborhood)
        end

        it "loads liked listings" do
          agent = create(:agent)
          listing = create(:listing)
          create(:heart, agent: agent, listing: listing)
          sign_in_as(agent)
          get :show, id: @hood.slug

          expect(assigns(:liked_listings)).to eq [listing.id]
        end

        it "returns an empty array if agent has no likes" do
          agent = create(:agent)
          sign_in_as(agent)
          get :show, id: @hood.slug

          expect(assigns(:liked_listings)).to eq []
        end

        it "returns an empty array if there is no agent" do
          get :show, id: @hood.slug

          expect(assigns(:liked_listings)).to eq []
        end
      end
    end

    describe "read methods" do
      before :each do
        @hood = create(:neighborhood, :with_listing)
      end

      it "shows visible neighborhoods" do
        hood2 = create(:neighborhood, featured: false)
        get :index

        expect(assigns(:neighborhoods)).to include @hood
        expect(assigns(:neighborhoods)).not_to include hood2
        expect(response).to render_template :index
      end

      it "shows a neighborhood and its listings" do
        listings = @hood.listings
        get :show, id: @hood.id

        expect(assigns(:neighborhood)).to eq @hood
        expect(assigns(:listings)).to eq listings
      end

      it "finds a neighborhood by slug" do
        get :show, id: @hood.slug

        expect(assigns(:neighborhood)).to eq @hood
        expect(response).to render_template :show
      end

      it "displays rooms" do
        invisible = create(:room_post, hidden: true, neighborhood: @hood)
        non_upcoming = create(:room_post, when: 1.month.ago, neighborhood: @hood)
        room = create(:room_post, neighborhood: @hood)
        get :rooms, id: @hood.slug

        expect(response).to render_template :rooms
        expect(assigns(:room_posts)).to include room
        expect(assigns(:room_posts)).not_to include non_upcoming
        expect(assigns(:room_posts)).not_to include invisible
        expect(assigns(:neighborhood)).to eq @hood
      end

      it "displays locations" do
        loc = create(:location, neighborhood: @hood)
        get :locations, id: @hood.slug

        expect(response).to render_template :locations
        expect(assigns(:neighborhood)).to eq @hood
        expect(assigns(:locations)).to eq [loc]
      end

      it "does not allow access to #new" do
        get :new

        expect(response).to redirect_to root_path
      end
    end

    describe "#mates" do
      render_views

      before :each do
        @hood = create(:neighborhood)
      end

      it "displays mates if agent has a provider" do
        sign_in_as(create(:agent, employee: false, provider: "facebook"))
        get :mates, id: @hood.slug

        expect(response).to render_template :mates
      end

      it "displays facebook message otherwise" do
        sign_in_as(create(:agent, employee: false))
        get :mates, id: @hood.slug

        expect(response.body).to match /Why\ Facebook?/
      end
    end
  end

  context "when agent is an employee" do
    it "does not allow agent to create a neighborhood" do
      @agent = create(:agent)
      sign_in_as(@agent)
      hood = build(:neighborhood)
      post :create, { neighborhood: hood.attributes }

      expect(response).to redirect_to root_path
      expect(Neighborhood.find_by(slug: hood.slug)).to be_nil
    end

    it "does not allow employees to delete neighborhoods" do
      hood = create(:neighborhood)
      delete :destroy, id: hood.slug

      expect(response).to redirect_to root_path
      expect(Neighborhood.find_by(slug: hood.slug)).not_to be_nil
    end
  end

  context "when agent is a super admin" do
    before :each do
      @agent = create(:agent, super_admin: true)
      sign_in_as(@agent)
      @hood = create(:neighborhood)
    end

    describe "GET #edit" do
      it "displays edit form" do
        get :edit, id: @hood.slug

        expect(assigns(:neighborhood)).to eq @hood
        expect(response).to render_template :edit
      end
    end

    describe "POST #create" do
      it "creates a neighborhood when attributes are valid" do
        hood2 = build(:neighborhood)
        post :create, { neighborhood: hood2.attributes }

        expect(assigns(:neighborhood).name).to eq hood2.name
        expect(response).to redirect_to neighborhoods_path
        expect(Neighborhood.find_by(name: hood2.name)).not_to be_nil
      end

      it "redirects to new when attributes are invalid" do
        hood2 = build(:neighborhood, region_id: nil)
        post :create, { neighborhood: hood2.attributes }

        expect(Neighborhood.find_by(name: hood2.name)).to be_nil
        expect(response).to render_template :new
      end
    end

    describe "PUT #update" do
      it "displays neighborhood when attributes are valid" do
        attrs = @hood.attributes
        attrs["name"] = "Bushburg"
        put :update, id: @hood.slug, neighborhood: attrs
        @hood.reload

        expect(assigns(:neighborhood)).to eq @hood
        expect(response).to redirect_to neighborhood_path(@hood)
        expect(@hood.name).to eq "Bushburg"
      end

      it "redirects to edit when attributes are invalid" do
        attrs = @hood.attributes
        attrs["name"] = nil
        put :update, id: @hood.slug, neighborhood: attrs
        @hood.reload

        expect(assigns(:neighborhood)).to eq @hood
        expect(response).to render_template :edit
        expect(@hood.region_id).not_to be_nil
      end
    end

    describe "DELETE #destroy" do
      it "can destroy a neighborhood" do
        slug = @hood.slug
        delete :destroy, id: slug

        expect(response).to redirect_to neighborhoods_path
        expect(Neighborhood.find_by(slug: slug)).to be_nil
      end
    end
  end
end
