describe LocationCategoriesController, type: :controller do
  context "when agent is a super admin" do
    before :each do
      sign_in_as(create(:agent, super_admin: true))
    end

    it "displays form to create a new category" do
      get :new

      expect(assigns(:location_category)).to be_a_new LocationCategory
      expect(response).to render_template :new
    end

    it "creates a new category" do
      lc = build(:location_category, name: "Entertainment")
      post :create, location_category: lc.attributes

      expect(LocationCategory.find_by(name: "Entertainment")).not_to be_nil
      expect(response).to redirect_to location_categories_path
    end

    describe "managing categories" do
      before :each do
        @lc = create(:location_category)
      end

      it "displays form to edit a category" do
        get :edit, id: @lc.id

        expect(assigns(:location_category)).to eq @lc
        expect(response).to render_template :edit
      end

      it "updates a category" do
        put :update, id: @lc.id, location_category: @lc.attributes.merge(name: "Food & Drink")

        expect(assigns(:location_category)).to eq @lc
        @lc.reload
        expect(@lc.name).to eq "Food & Drink"
        expect(response).to redirect_to location_category_path(@lc)
      end

      it "deletes a category" do
        delete :destroy, id: @lc.id

        expect(assigns(:location_category)).to eq @lc
        expect(response).to redirect_to location_categories_url
        expect(LocationCategory.find_by(id: @lc.id)).to be_nil
      end
    end
  end

  context "when agent is a regular agent" do
    it "displays all location categories" do
      get :index

      expect(response).to render_template :index
    end

    it "shows a particular category" do
      lc = create(:location_category)
      locations = create_list(:location, 2, location_category: lc)
      get :show, id: lc.id

      expect(assigns(:location_category)).to eq lc
      expect(assigns(:locations)).to eq locations
      expect(response).to render_template :show
    end

    it "does not display form to create a category" do
      get :new

      expect(response).to redirect_to root_path
    end
  end
end
