describe Matrix::PagesController, type: :controller do
  context "when agent is an employee" do
    before :each do
      sign_in_as(create(:agent))
    end

    it "displays agent guide" do
      get :agent_guide

      expect(response).to render_template :agent_guide
    end

    it "displays documents" do
      get :documents

      expect(response).to render_template :documents
    end

    it "displays statistics" do
      get :statistics

      expect(response).to render_template :statistics
    end
  end

  context "when agent is not an employee" do
    before :each do
      sign_in_as(create(:agent, employee: false))
    end

    it "does not display pages" do
      get :statistics

      expect(response).to redirect_to root_path
    end
  end
end
