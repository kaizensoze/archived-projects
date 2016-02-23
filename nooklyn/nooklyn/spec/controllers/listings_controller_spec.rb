describe ListingsController, type: :controller do
  context "with an ordinary agent" do
    before :each do
      @agent = create(:agent, employee: false)
      sign_in_as(@agent)
      @listing = create(:listing)
    end

    describe "GET #index" do
      it "gets and orders listings" do
        get :index
        expect(response).to render_template :index
      end
    end

    describe "GET #rentals" do
      it "displays rentals" do
        get :rentals
        expect(assigns(:page_name)).to eq "Rentals"
        expect(response).to render_template :index
      end
    end

    describe "GET #sales" do
      it "displays sales" do
        get :sales
        expect(assigns(:page_name)).to eq "Sales"
        expect(response).to render_template :index
      end
    end

    describe "GET #show" do
      it "redirects to index when listing is private" do
        @listing.update_attribute(:private, true)
        get :show, id: @listing.id

        expect(assigns(:listing)).to eq @listing
        expect(response).to redirect_to(action: :index)
      end

      it "renders when listing is not private" do
        photos = create_list(:photo, 2, listing: @listing)
        get :show, id: @listing.id

        expect(assigns(:listing)).to eq @listing
        expect(assigns(:photos)).to eq photos
      end
    end

    describe "GET #like" do
      it "adds a like to the listing" do
        get :like, id: @listing.id

        expect(response).to redirect_to(action: :show)
        expect(@listing.likes.count).to eq 1
      end

      it "does not create a like if agent already likes that listing" do
        create(:heart, listing: @listing, agent: @agent)
        get :like, id: @listing.id

        expect(response).to redirect_to(action: :show)
        expect(@listing.likes.count).to eq 1
      end
    end

    describe "GET #unlike" do
      it "destroys a like when one is present" do
        create(:heart, listing: @listing, agent: @agent)
        get :unlike, id: @listing.id

        expect(response).to redirect_to(action: :show)
        expect(@listing.likes.count).to eq 0
      end
    end

    describe "GET #manage_photos" do
      it "redirects to login" do
        get :manage_photos, id: @listing.id

        expect(response).to redirect_to root_path
      end
    end

    describe "GET #craigslist" do
      it "does not allow access" do
        get :craigslist, id: @listing.id

        expect(response).to redirect_to root_path
      end
    end
  end

  context "when agent is not signed in" do
    describe "GET #index" do
      it "allows access" do
        get :index

        expect(response).to render_template :index
        expect(response.status).to eq 200
      end
    end

    describe "GET #like" do
      it "does not allow access" do
        get :like, id: create(:listing).id

        expect(response).to redirect_to root_path
      end
    end
  end

  context "when agent is suspended" do
    describe "GET #index" do
      it "does not allow access" do
        agent = create(:agent, suspended: true)
        sign_in_as(agent)
        get :index

        expect(response).to redirect_to root_path
      end
    end
  end

  context "when agent is an employee" do
    before :each do
      @agent = create(:agent)
      sign_in_as(@agent)
    end

    describe "GET #craigslist" do
      it "renders the craigslist template" do
        get :craigslist, id: create(:listing).id

        expect(response).to render_template "craigslist"
      end
    end

    describe "GET #new" do
      it "renders the new template" do
        get :new

        expect(assigns(:listing)).to be_a_new Listing
        expect(response).to render_template :new
      end
    end

    describe "GET #edit" do
      it "renders the edit template" do
        listing = create(:listing, sales_agent: @agent)
        get :edit, id: listing.id

        expect(response).to render_template :edit
      end
    end

    describe "POST #create" do
      it "creates a listing with valid attributes" do
        listing = build(:listing, listing_agent_id: @agent.id)
        post :create, { listing: listing.attributes }

        new_listing = Listing.find_by(title: listing.title)
        expect(new_listing).not_to be_nil
        expect(response).to redirect_to listing_path(new_listing)
      end

      it "renders new without valid attributes" do
        listing = build(:listing, address: nil)
        post :create, { listing: listing.attributes }

        expect(Listing.find_by(title: listing.title)).to be_nil
        expect(response).to render_template :new
      end
    end

    describe "PUT #update" do
      before :each do
        @listing = create(:listing, sales_agent: @agent)
        @attrs = @listing.attributes
      end

      it "updates the listing with valid attributes" do
        @attrs[:address] = "242 Thistle Ave"
        put :update, id: @listing.id, listing: @attrs
        @listing.reload

        expect(@listing.address).to eq "242 Thistle Ave"
        expect(response).to redirect_to listing_path(@listing)
      end

      it "renders edit without valid attributes" do
        @attrs[:address] = nil
        put :update, id: @listing.id, listing: @attrs
        @listing.reload

        expect(@listing.address).to eq "225 Morgan Ave"
        expect(response).to render_template :edit
      end
    end

    describe "DELETE #destroy" do
      it "does not allow access" do
        listing = create(:listing)
        delete :destroy, id: listing.id

        expect(response).to redirect_to root_path
        expect(Listing.find(listing.id)).to eq listing
      end
    end
  end

  context "when agent is a super_admin" do
    before :each do
      @agent = create(:agent, super_admin: true)
      sign_in_as(@agent)
      @listing = create(:listing)
    end

    describe "DELETE #destroy" do
      it "destroys the record" do
        id = @listing.id
        delete :destroy, id: id

        expect(Listing.find_by(id: id)).to be_nil
        expect(response).to redirect_to listings_path
      end
    end
  end
end
