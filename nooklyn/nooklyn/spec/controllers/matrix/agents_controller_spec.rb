describe Matrix::AgentsController, type: :controller do
  context "when agent is an employer" do
    before :each do
      sign_in_as(create(:agent, employer: true))
    end

    it "displays all employees" do
      get :index

      expect(response).to render_template :index
    end

    it "displays all non-employees" do
      get :hire

      expect(response).to render_template :index
    end

    it "displays all employees on probation" do
      get :probation

      expect(response).to render_template :index
    end

    describe "managing employees" do
      before :each do
        @agent = create(:agent)
      end

      it "places an employee on probation" do
        get :place_on_probation, id: @agent

        @agent.reload
        expect(@agent.on_probation).to eq true
        expect(response).to redirect_to matrix_agents_path
      end

      it "removes an employee from probation" do
        @agent.update(on_probation: true)
        get :remove_from_probation, id: @agent.id

        @agent.reload
        expect(@agent.on_probation).to eq false
        expect(response).to redirect_to matrix_agents_path
      end

      it "places an employee on suspension" do
        get :place_on_suspension, id: @agent.id

        @agent.reload
        expect(@agent.suspended).to eq true
        expect(response).to redirect_to matrix_agents_path
      end

      it "removes an employee from suspension" do
        @agent.update(suspended: true)
        get :remove_from_suspension, id: @agent.id

        @agent.reload
        expect(@agent.suspended).to eq false
        expect(response).to redirect_to matrix_agents_path
      end

      it "employs an agent" do
        @agent.update(employee: false)
        get :employ, id: @agent.id

        @agent.reload
        expect(@agent.employee).to eq true
        expect(response).to redirect_to matrix_agents_path
      end

      it "fires an agent" do
        get :fire, id: @agent.id

        @agent.reload
        expect(@agent.employee).to eq false
        expect(response).to redirect_to matrix_agents_path
      end
    end
  end

  context "when agent is an employee" do
    before :each do
      sign_in_as(create(:agent))
    end

    it "displays all employees" do
      get :index

      expect(response).to render_template :index
    end

    it "does not display all non-employees" do
      get :hire

      expect(response).to redirect_to root_path
    end
  end

  context "when agent is not an employee" do
    it "does not display all employees" do
      get :index

      expect(response).to redirect_to root_path
    end
  end
end
