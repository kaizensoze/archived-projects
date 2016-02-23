describe FeedbacksController, type: :controller do
  context "with any agent" do
    it "displays form to create new feedback" do
      get :new

      expect(assigns(:feedback)).to be_a_new Feedback
      expect(response).to render_template :new
    end

    it "creates new feedback" do
      feedback = build(:feedback, message: "Hello!")
      post :create, feedback: feedback.attributes

      expect(assigns(:feedback).message).to eq "Hello!"
      expect(response).to redirect_to root_path
      expect(Feedback.find_by(message: "Hello!")).not_to be_nil
    end

    it "does not display index" do
      get :index

      expect(response).to redirect_to root_path
    end
  end

  context "when agent is a super admin" do
    before :each do
      sign_in_as(create(:agent, super_admin: true))
      @feedback = create(:feedback)
    end

    it "displays index" do
      create_list(:feedback, 2)
      get :index

      expect(response).to render_template :index
    end

    it "displays a particular feedback" do
      get :show, id: @feedback.id

      expect(assigns(:feedback)).to eq @feedback
      expect(response).to render_template :show
    end

    it "displays form to edit feedback" do
      get :edit, id: @feedback.id

      expect(assigns(:feedback)).to eq @feedback
      expect(response).to render_template :edit
    end

    it "updates feedback" do
      put :update, id: @feedback.id, feedback: @feedback.attributes.merge(message: "Hi there!")

      expect(assigns(:feedback)).to eq @feedback
      expect(response).to redirect_to feedback_path(@feedback)
      @feedback.reload
      expect(@feedback.message).to eq "Hi there!"
    end

    it "destroys feedback" do
      delete :destroy, id: @feedback.id

      expect(assigns(:feedback)).to eq @feedback
      expect(Feedback.find_by(id: @feedback.id)).to be_nil
      expect(response).to redirect_to feedbacks_path
    end
  end
end
