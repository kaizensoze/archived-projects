describe LeadsController, type: :controller do
  context "when agent is an employee" do
    before :each do
      agent = create(:agent)
      sign_in_as(agent)
    end

    it "displays upcoming leads" do
      get :index

      expect(response).to render_template :index
    end

    it "displays a particular lead" do
      lead = create(:lead)
      get :show, id: lead.id

      expect(assigns(:lead)).to eq lead
      expect(response).to render_template :show
    end

    describe "creating a lead" do
      it "redirects to the lead after submit" do
        attrs = build(:lead).attributes
        post :create, lead: attrs

        expect(response).to redirect_to assigns(:lead)
      end
    end

    describe "updating a lead" do
      before :each do
        @lead = create(:lead)
      end

      it "displays the edit form" do
        get :edit, id: @lead.id
      end

      it "updates the lead" do
        attrs = @lead.attributes
        attrs[:full_name] = "Allison Crutchfield"
        put :update, id: @lead.id, lead: attrs
      end
    end

    it "cannot destroy a lead" do
      lead = create(:lead)
      delete :destroy, id: lead.id

      expect(response).to redirect_to root_path
    end
  end

  context "when agent is not an employee" do
    before :each do
      sign_in_as(create(:agent, employee: false))
    end

    describe "creating a lead" do
      it "displays form to create a lead" do
        get :new

        expect(response).to render_template :new
      end

      it "redirects to contact form after submit" do
        attrs = build(:lead).attributes
        post :create, lead: attrs

        expect(response).to redirect_to contact_path
      end
    end

    describe "editing a lead" do
      before :each do
        @lead = create(:lead)
      end

      it "cannot access edit form" do
        get :edit, id: @lead.id

        expect(response).to redirect_to root_path
      end

      it "cannot update a lead" do
        put :update, id: @lead.id, lead: @lead.attributes

        expect(response).to redirect_to root_path
      end
    end

    describe "reading leads" do
      it "cannot view leads" do
        get :index

        expect(response).to redirect_to root_path
      end
    end
  end

  context "when agent is a super admin" do
    it "can destroy a lead" do
      sign_in_as(create(:agent, super_admin: true))
      lead = create(:lead)
      delete :destroy, id: lead.id

      expect(Lead.find_by(id: lead.id)).to be_nil
      expect(response).to redirect_to leads_path
    end
  end

  context "when agent is suspended" do
    before :each do
      sign_in_as(create(:agent, suspended: true))
    end

    it "can create a lead" do
      attrs = build(:lead, full_name: "Dave Shumka").attributes
      post :create, lead: attrs

      expect(response).to redirect_to contact_path
      expect(Lead.find_by(full_name: "Dave Shumka")).not_to be_nil
    end

    it "cannot read leads" do
      get :index

      expect(response).to redirect_to root_path
    end
  end
end
