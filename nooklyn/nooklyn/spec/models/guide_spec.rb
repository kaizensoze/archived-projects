describe Guide do
  describe "assocations" do
    it { should belong_to :neighborhood }
    it { should have_many :guide_stories }
  end

  describe "#neighborhood_name" do
    it "returns the name of the neighborhood" do
      hood = build_stubbed(:neighborhood, name: "Vrsovice")
      guide = build(:guide, neighborhood: hood)

      expect(guide.neighborhood_name).to eq "Vrsovice"
    end
  end
end
