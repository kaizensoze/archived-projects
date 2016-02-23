describe Matrix::NeighborhoodsController, type: :controller do
  before :each do
    @hood1 = create(:neighborhood, region_id: 3)
    @hood2 = create(:neighborhood, region_id: 1)
    @listing1 = create(:listing, status: "Available", neighborhood: @hood1)
    @listing2 = create(:listing, status: "Rented", neighborhood: @hood1)
  end

  context "when agent is an employee" do
    before :each do
      sign_in_as(create(:agent))
    end

    it "shows neighborhood and available listings" do
      get :show, id: @hood1.slug

      expect(assigns(:neighborhood)).to eq @hood1
      expect(assigns(:neighborhoods)).to include @hood2
      expect(assigns(:listings)).to eq [@listing1]
      expect(response).to render_template :show
    end

    it "shows neighborhood and rented listings" do
      get :rented, id: @hood1.slug

      expect(assigns(:listings)).to eq [@listing2]
    end
  end

  context "when agent is not an employee" do
    it "does not show" do
      sign_in_as(create(:agent, employee: false))
      get :show, id: @hood1.id

      expect(response).to redirect_to root_path
    end
  end
end
