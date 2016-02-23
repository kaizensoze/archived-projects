describe Location do
  describe "validations" do
    it { should validate_presence_of(:name) }
    it { should validate_presence_of(:latitude) }
    it { should validate_presence_of(:longitude) }
    it { should validate_presence_of(:address_line_one) }
    it { should validate_presence_of(:city) }
    it { should validate_presence_of(:state) }
    it { should validate_presence_of(:zip) }
    it { should have_attached_file(:image) }
    it { should validate_attachment_content_type(:image).allowing("image/jpg").rejecting("text/plain") }
  end

  describe "associations" do
    it { should belong_to(:neighborhood) }
    it { should belong_to(:location_category) }
  end

  describe "#to_param" do
    it "returns a param" do
      location = build(:location, id: 3, slug: "im_a_slug")
      expect(location.to_param).to eq "3-im_a_slug"
    end
  end

  describe "#full_address" do
    it "returns the concatenated address" do
      location = build(:location, address_line_one: "4 Privet Drive",
                                  city: "Brooklyn",
                                  state: "NY",
                                  zip: 11206)

      expect(location.full_address).to eq "4 Privet Drive\nBrooklyn, NY 11206"
    end
  end
end
