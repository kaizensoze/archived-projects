describe Neighborhood do
  describe "associations" do
    it { should have_many(:listings) }
    it { should have_many(:locations) }
    it { should have_many(:room_posts) }
    it { should have_many(:mate_posts) }
    it { should belong_to(:region) }
  end

  describe "validations" do
    it { should validate_presence_of(:name) }
    it { should validate_presence_of(:region_id) }
    it { should validate_uniqueness_of(:slug) }
    it { should have_attached_file(:image) }
    it { should validate_attachment_content_type(:image).allowing("image/jpg").rejecting("text/plain") }
  end

  describe "scopes" do
    it "finds neighborhoods by region" do
      brooklyn = create(:neighborhood, region_id: 1)
      queens = create(:neighborhood, region_id: 3)
      other = create(:neighborhood, region_id: 2)

      expect(Neighborhood.brooklyn).to include brooklyn
      expect(Neighborhood.queens).to include queens

      brooklyn_and_queens = Neighborhood.brooklyn_and_queens
      expect(brooklyn_and_queens).to include brooklyn
      expect(brooklyn_and_queens).to include queens
      expect(brooklyn_and_queens).not_to include other
    end

    it "orders by name" do
      a = create(:neighborhood, name: "Alsburg")
      z = create(:neighborhood, name: "Zergswick")

      expect(Neighborhood.ordered_name.index(a)).to be < Neighborhood.ordered_name.index(z)
    end

    it "finds neighborhoods by visibility" do
      visible = create(:neighborhood)
      invisible = create(:neighborhood, featured: false)

      expect(Neighborhood.visible).to include visible
      expect(Neighborhood.visible).not_to include invisible
    end
  end

  describe "#full_name" do
    it "returns the full name" do
      hood = build(:neighborhood, name: "Flushwick", borough: "Staten Island")

      expect(hood.full_name).to eq "Flushwick, Staten Island, NY"
    end
  end

  describe "#to_param" do
    it "returns the slug" do
      hood = build(:neighborhood)

      expect(hood.to_param).to eq hood.slug
    end
  end
end
