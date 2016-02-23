describe PhotosController, type: :controller do
  context "when agent is an employee" do
    before :each do
      sign_in_as(create(:agent))
    end

    it "displays index" do
      get :index

      expect(response).to render_template :index
    end

    it "displays a particular photo" do
      photo = create(:photo)
      get :show, id: photo.id

      expect(assigns(:photo)).to eq photo
      expect(response).to render_template :show
    end

    it "creates a new photo" do
      listing = create(:listing)
      post :create, photo: { listing_id: listing.id, image: fixture_file_upload("photo.jpg", "image/jpg") }

      expect(assigns(:listing)).to eq listing
      expect(response).to be_a_success
      expect(assigns(:photo).listing).to eq listing
      expect(assigns(:photo).image_file_name).to eq "photo.jpg"
    end

    describe "managing photos" do
      before :each do
        @photo = create(:photo, :with_listing)
      end

      it "displays form to edit a photo" do
        get :edit, id: @photo.id

        expect(assigns(:photo)).to eq @photo
        expect(response).to render_template :edit
      end

      it "updates a photo" do
        listing = create(:listing)
        put :update, id: @photo.id, photo: { listing_id: listing.id }
        @photo.reload

        expect(response).to redirect_to photo_path(@photo)
        expect(@photo.listing).to eq listing
        expect(@photo.image_file_name).to eq "photo.jpg"
      end

      it "deletes a photo" do
        delete :destroy, id: @photo.id

        expect(assigns(:photo)).to eq @photo
        expect(response).to redirect_to manage_photos_listing_path(@photo.listing)
        expect(Photo.find_by(id: @photo.id)).to be_nil
      end
    end
  end

  context "when agent is not an employee" do
    it "does not display index" do
      get :index

      expect(response).to redirect_to root_path
    end
  end

  context "when agent is suspended" do
    before :each do
      sign_in_as(create(:agent, suspended: true))
    end

    it "does not display index" do
      get :index

      expect(response).to redirect_to root_path
    end

    it "cannot destroy a photo" do
      photo = create(:photo)
      delete :destroy, id: photo.id

      expect(response).to redirect_to root_path
    end
  end
end
