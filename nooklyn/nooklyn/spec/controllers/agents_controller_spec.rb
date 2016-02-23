describe AgentsController, type: :controller do
  context "when agent is not signed in" do
    it "displays index" do
      agent = create(:agent)
      get :index
      expect(response).to render_template :index
    end

    it "displays a particular agent" do
      agent = create(:agent)
      room_post_like = create(:room_post_like, agent: agent)
      mate_post_like = create(:mate_post_like, agent: agent)
      get :show, id: agent.id

      expect(agent.room_post_likes).to eq [room_post_like]
      expect(agent.mate_post_likes).to eq [mate_post_like]
      expect(response).to render_template :show
    end

    it "does not display a private profile" do
      agent = create(:agent, private_profile: true)
      get :show, id: agent.id

      expect(response).to redirect_to root_path
    end

    it "does not display room favorites" do
      get :rm_favorites

      expect(response).to redirect_to root_path
    end
  end

  context "when agent is signed in" do
    before :each do
      @agent = create(:agent, employee: false)
      sign_in_as(@agent)
    end

    it "displays room favorites" do
      get :rm_favorites

      expect(response).to render_template :rm_favorites
    end

    it "displays room settings" do
      get :rm_settings

      expect(response).to render_template :rm_settings
    end

    it "displays room leads" do
      get :rm_leads

      expect(response).to render_template :rm_leads
    end

    it "displays a particular agent's collections" do
      get :my_collections

      expect(response).to render_template :my_collections
    end
  end
end
