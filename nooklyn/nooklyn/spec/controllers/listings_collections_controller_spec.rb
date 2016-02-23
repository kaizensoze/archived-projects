describe ListingsCollectionsController, type: :controller do
  describe "#show" do
    before :each do
      @collection = create(:listings_collection)
    end

    it "displays a collection" do
      get :show, id: @collection.id

      expect(response).to render_template :show
    end

    it "finds a collection by slug" do
      get :show, id: @collection.id

      expect(assigns(:listings_collection)).to eq @collection
      expect(response).to render_template :show
    end
  end

  describe "#create" do
    context "when agent is signed in" do
      before :each do
        @agent = create(:agent, employee: false)
        sign_in_as(@agent)
        @listing = create(:listing)
      end

      it "displays form to create a new collection" do
        get :new

        expect(assigns(:listings_collection)).to be_a_new ListingsCollection
        expect(assigns(:listings)).to eq @listings
        expect(response).to render_template :new
      end

      it "displays form with chosen listing" do
        get :new, listing_id: @listing.id

        expect(assigns(:listing)).to eq @listing
        expect(response).to render_template :new
      end

      it "creates a new collection" do
        post :create, listings_collection: { name: "Great Collection", listing_ids: [@listing.id] }

        collection = ListingsCollection.first
        expect(response).to redirect_to listings_collection_path(collection)
        expect(collection.agent).to eq @agent
        expect(collection.listings.pluck(:id)).to eq [@listing.id]
        expect(collection.name).to eq "Great Collection"
        expect(collection.slug).to match /\Agreat-collection/
      end
    end

    context "when agent is not signed in" do
      it "does not display form to create a collection" do
        get :new

        expect(response).to redirect_to root_path
      end
    end
  end

  describe "#edit" do
    before :each do
      @agent = create(:agent)
      sign_in_as(@agent)
    end

    context "when collection belongs to agent" do
      before :each do
        @collection = create(:listings_collection, agent: @agent)
      end

      it "displays form to edit collection" do
        get :edit, id: @collection.id

        expect(assigns(:listings)).to eq @collection.listings
        expect(response).to render_template :edit
      end

      it "updates a collection's members" do
        attrs = @collection.attributes
        listing = @collection.listings[1]
        put :update, id: @collection.id, listings_collection: attrs.merge(listing_ids: [listing.id])
        @collection.reload

        expect(response).to redirect_to listings_collection_path(@collection)
        expect(@collection.listings).to eq [listing]
      end

      it "changes the name and slug of a collection" do
        attrs = @collection.attributes
        put :update, id: @collection.id, listings_collection: attrs.merge(name: "My Best Collection")
        @collection.reload

        expect(response).to redirect_to listings_collection_path(@collection)
        expect(@collection.name).to eq "My Best Collection"
        expect(@collection.slug).to match /\Amy-best-collection/
      end

      it "adds a listing to the collection" do
        new_listing = create(:listing)
        post :add_listing, id: @collection.id, listing_id: new_listing.id

        expect(@collection.listings).to include new_listing
      end

      it "removes a listing from the collection" do
        listing = @collection.listings[0]
        post :remove_listing, id: @collection.id, listing_id: listing.id
        @collection.reload

        expect(@collection.listings).not_to include listing
      end
    end

    context "when collection does not belong to agent" do
      it "does not display edit form" do
        collection = create(:listings_collection)
        get :edit, id: collection.id

        expect(response).to redirect_to root_path
      end
    end
  end

  describe "public and private" do
    before :each do
      @agent = create(:agent)
      @collection = create(:listings_collection, agent: @agent)
      sign_in_as(@agent)
    end

    it "makes a public listing private" do
      get :make_private, id: @collection.id
      @collection.reload

      expect(response).to redirect_to my_collections_path(@agent)
      expect(@collection).to be_private
    end

    it "makes a private listing public" do
      @collection.update_attributes(private: true)
      get :make_public, id: @collection.id
      @collection.reload

      expect(response).to redirect_to my_collections_path(@agent)
      expect(@collection).not_to be_private
    end
  end
end
