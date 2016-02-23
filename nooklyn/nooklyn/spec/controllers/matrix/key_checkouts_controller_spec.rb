describe Matrix::KeyCheckoutsController, type: :controller do
  context "when agent is an employee" do
    before :each do
      @agent = create(:agent)
      sign_in_as(@agent)
      @key = build(:key_checkout, agent: @agent, message: "Hello!")
    end

    it "renders form to check out key" do
      get :new

      expect(response).to render_template :new
    end

    it "creates a key checkout" do
      post :create, key_checkout: @key.attributes

      expect(KeyCheckout.find_by(message: "Hello!")).not_to be_nil
      expect(response).to redirect_to matrix_key_checkouts_path
    end

    it "cannot edit a key checkout" do
      @key.save
      get :edit, id: @key.id

      expect(response).to redirect_to root_path
    end

    it "can return a key" do
      @key.save
      get :return, id: @key.id
      @key.reload

      expect(@key.returned).to eq true
      expect(response).to redirect_to matrix_key_checkouts_path
    end

    it "can view key checkouts" do
      get :index

      expect(response).to render_template :index
    end
  end

  context "when agent is suspended" do
    it "cannot create a key checkout" do
      sign_in_as(create(:agent, suspended: true))
      get :new

      expect(response).to redirect_to root_path
    end
  end

  context "when agent is not an employee" do
    it "cannot create a key checkout" do
      sign_in_as(create(:agent, employee: false))
      get :new

      expect(response).to redirect_to root_path
    end
  end

  context "when agent is a super admin" do
    before :each do
      sign_in_as(create(:agent, super_admin:  true))
      @key = create(:key_checkout, message: "Hi")
    end

    it "renders form to edit a key checkout" do
      get :edit, id: @key.id

      expect(response).to render_template :edit
    end

    it "updates a key checkout" do
      put :update, id: @key.id, key_checkout: @key.attributes.merge(message: "Hello")
      @key.reload

      expect(@key.message).to eq "Hello"
      expect(response).to render_template :show
    end

    it "destroys a key checkout" do
      delete :destroy, id: @key.id

      expect(KeyCheckout.find_by(message: "Hi")).to be_nil
    end
  end
end
