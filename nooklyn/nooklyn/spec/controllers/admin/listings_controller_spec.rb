describe Admin::ListingsController, type: :controller do
  context "when agent is a super admin" do
    before :each do
      sign_in_as(create(:agent, super_admin: true))
    end

    it "displays index" do
      get :index

      expect(response).to render_template :index
    end

    it "displays a listing" do
      listing = create(:listing)
      get :show, id: listing.id

      expect(response).to render_template :show
    end

    it "displays search results" do
      get :search

      expect(response).to render_template :search
    end
  end

  context "when agent is not a super admin" do
    it "does not display pages" do
      sign_in_as(create(:agent))
      get :index

      expect(response).to redirect_to root_path
    end
  end
end
