describe ListingsCollection do
  describe "validations" do
    subject { build_stubbed(:listings_collection, slug: "cool-collection") }
    it { should validate_presence_of(:agent) }
    it { should validate_presence_of(:name) }
    it { should allow_value(true).for(:featured) }
  end

  describe "associations" do
    it { should belong_to(:agent) }
    it { should have_many(:listings_collection_memberships) }
    it { should have_many(:listings).through(:listings_collection_memberships) }
  end
end
