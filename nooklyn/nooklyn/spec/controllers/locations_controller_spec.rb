describe LocationsController, type: :controller do
  context "with any agent" do
    it "renders index" do
      get :index

      expect(response).to render_template :index
    end

    it "renders a particular location" do
      loc = create(:location)
      get :show, id: loc.id

      expect(assigns(:location)).to eq loc
      expect(response).to render_template :show
    end

    it "cannot create a location" do
      get :new

      expect(response).to redirect_to root_path
    end
  end

  context "when agent is an employee" do
    before :each do
      sign_in_as(create(:agent))
      @loc = build(:location, name: "Central Cafe")
    end

    describe "create" do
      it "renders form to create a new location" do
        get :new

        expect(response).to render_template :new
      end

      it "creates a new location" do
        post :create, location: @loc.attributes

        expect(response).to redirect_to locations_path
        expect(Location.find_by(name: @loc.name)).not_to be_nil
      end
    end

    describe "change existing locations" do
      before :each do
        @loc.save
      end

      it "renders form to edit a location" do
        get :edit, id: @loc.id

        expect(response).to render_template :edit
      end

      it "updates a location" do
        attrs = @loc.attributes
        attrs[:name] = "Molasses Books"
        put :update, id: @loc.id, location: attrs
        @loc.reload

        expect(response).to redirect_to location_path(@loc)
        expect(@loc.name).to eq "Molasses Books"
      end

      it "cannot delete a location" do
        delete :destroy, id: @loc.id

        expect(response).to redirect_to root_path
        expect(Location.find(@loc.id)).to eq @loc
      end
    end
  end

  context "when agent is suspended" do
    it "cannot create a location" do
      sign_in_as(create(:agent, suspended: true))
      get :new

      expect(response).to redirect_to root_path
    end
  end

  context "when agent is a super admin" do
    it "can delete a location" do
      sign_in_as(create(:agent, super_admin: true))
      loc = create(:location)
      delete :destroy, id: loc.id

      expect(response).to redirect_to locations_path
      expect(Location.find_by(id: loc.id)).to be_nil
    end
  end
end
