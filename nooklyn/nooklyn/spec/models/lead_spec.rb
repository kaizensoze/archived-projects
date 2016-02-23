describe Lead do
  describe "validations" do
    it { should validate_presence_of(:full_name) }
    it { should validate_presence_of(:phone) }
    it { should validate_presence_of(:max_price) }
    it { should validate_presence_of(:move_in) }
  end

  describe "associations" do
    it { should belong_to(:agent) }
    it { should have_many(:updates).class_name("LeadUpdate").dependent(:destroy) }
    it { should have_many(:agents).through(:updates) }
  end

  describe "scopes" do
    before :each do
      @l1 = create(:lead, move_in: Time.now + 15.days)
      @l2 = create(:lead, move_in: Time.now + 45.days)
      @l3 = create(:lead, move_in: Time.now + 75.days)
    end
  end
end
