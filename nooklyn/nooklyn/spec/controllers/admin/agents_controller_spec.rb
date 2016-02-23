describe Admin::AgentsController, type: :controller do
  it "does not allow non-admins to access it" do
    sign_in_as(create(:agent))
    get :index

    expect(response).to redirect_to root_path
  end

  context "when agent is a super admin" do
    before :each do
      sign_in_as(create(:agent, super_admin: true))
    end

    it "displays all agents" do
      get :index

      expect(response).to render_template :index
    end

    it "displays particular agent" do
      ag = create(:agent)
      get :show, id: ag.id

      expect(response).to render_template :show
    end

    it "displays search results" do
      get :search

      expect(response).to render_template :search
    end
  end
end
