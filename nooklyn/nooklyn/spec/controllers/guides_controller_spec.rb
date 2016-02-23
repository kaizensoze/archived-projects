describe GuidesController, type: :controller do
  context "agent is a super admin" do
    before :each do
      sign_in_as(create(:agent, super_admin: true))
      @guide = create(:guide)
    end

    it "renders the edit form" do
      get :edit, id: @guide.id

      expect(assigns(:guide)).to eq @guide
      expect(response).to render_template :edit
    end

    it "renders the new form" do
      get :new

      expect(assigns(:guide)).to be_a_new Guide
    end

    it "creates a new guide" do
      @guide2 = build(:guide, title: "The Galaxy")
      post :create, guide: @guide2.attributes

      expect(assigns(:guide).title).to eq "The Galaxy"
      expect(response).to render_template :show
      expect(Guide.find_by(title: "The Galaxy")).not_to be_nil
    end

    it "updates a guide" do
      put :update, id: @guide.id, guide: @guide.attributes.merge(title: "The West")
      @guide.reload

      expect(assigns(:guide)).to eq @guide
      expect(@guide.title).to eq "The West"
      expect(response).to render_template :show
    end

    it "deletes a guide" do
      delete :destroy, id: @guide.id

      expect(Guide.find_by(id: @guide.id)).to be_nil
      expect(response).to render_template :index
    end
  end

  context "agent is not a super admin" do
    it "displays all guides" do
      get :index
      expect(response).to render_template :index
    end

    it "shows a guide" do
      guide = create(:guide)
      get :show, id: guide.id

      expect(assigns(:guide)).to eq guide
      expect(response).to render_template :show
    end

    it "cannot create a guide" do
      get :new

      expect(response).to redirect_to root_path
    end
  end
end
