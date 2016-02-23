describe Matrix::ListingsController, type: :controller do
  describe "when agent is a super admin" do
    it "can do anything" do
      agent = create(:agent, super_admin: true)
      sign_in_as(agent)

      get :table_view

      expect(response).to be_a_success
    end
  end

  context "when agent is an employee" do
    before :each do
      @agent = create(:agent)
      sign_in_as(@agent)
    end

    describe "GET #index" do
      it "displays index of all available listings" do
        unavailable = create(:listing, status: "Application Pending")
        invisible = create(:listing, private: true)
        get :index

        expect(assigns(:listings)).to include invisible
        expect(assigns(:listings)).not_to include unavailable
        expect(response).to render_template :index
      end
    end

    describe "GET #my_listings" do
      it "shows available listings where current agent is sales agent" do
        listing = create(:listing, sales_agent_id: @agent.id)
        unavailable = create(:listing, status: "Application Pending", sales_agent_id: @agent.id)
        not_yours = create(:listing, sales_agent_id: nil)
        get :my_listings

        expect(assigns(:listings)).to include listing
        expect(assigns(:listings)).not_to include unavailable
        expect(assigns(:listings)).not_to include not_yours
        expect(response).to render_template :my_listings
      end
    end

    describe "GET #pending" do
      it "shows all pending listings" do
        pending = create(:listing, status: "Application Pending")
        available = create(:listing, status: "Available")
        get :pending

        expect(assigns(:listings)).to include pending
        expect(assigns(:listings)).not_to include available
        expect(response).to render_template :index
      end
    end

    describe "GET #sales" do
      it "displays available sales" do
        rental = create(:listing, rental: true)
        unavailable = create(:listing, status: "Application Pending", rental: false)
        sale = create(:listing, rental: false)
        get :sales

        expect(assigns(:listings)).to include sale
        expect(assigns(:listings)).not_to include unavailable
        expect(assigns(:listings)).not_to include rental
        expect(response).to render_template :index
      end
    end

    describe "GET #rented" do
      it "shows all rented listings" do
        rented = create(:listing, status: "Rented")
        not_rented = create(:listing, status: "Available")
        get :rented

        expect(assigns(:listings)).to include rented
        expect(assigns(:listings)).not_to include not_rented
        expect(response).to render_template :index
      end
    end

    describe "GET #my_rented" do
      it "displays rented listings belonging to the agent" do
        rented = create(:listing, status: "Rented", sales_agent_id: @agent.id, listing_agent_id: @agent.id)
        not_yours1 = create(:listing, status: "Rented", sales_agent_id: @agent.id, listing_agent_id: nil)
        not_yours2 = create(:listing, status: "Rented", sales_agent_id: nil, listing_agent_id: @agent.id)
        get :my_rented

        expect(assigns(:listings)).to include rented
        expect(assigns(:listings)).not_to include not_yours1
        expect(assigns(:listings)).not_to include not_yours2
        expect(assigns(:page_name)).to eq "Rented"
        expect(response).to render_template :index
      end
    end

    describe "GET #table_view" do
      it "allows access" do
        get :table_view

        expect(response).to render_template :table_view
      end
    end
  end

  describe "when agent is not an employee" do
    it "does not allow access" do
      agent = create(:agent, employee: false)
      sign_in_as(agent)
      get :pending

      expect(response).to redirect_to root_path
    end
  end

  describe "when agent is suspended" do
    it "does not allow access" do
      agent = create(:agent, suspended: true)
      sign_in_as(agent)
      get :index

      expect(response).to redirect_to root_path
    end
  end
end
