describe Listing do
  describe "validations" do
    it { should validate_presence_of(:latitude).with_message("Pin location is required") }
    it { should validate_presence_of(:longitude).with_message("Pin location is required") }
    it { should validate_presence_of(:rental).with_message("Must specify lease or sale") }
    it { should_not allow_value(nil).for(:residential).with_message("Must specify residential or commercial") }
    it { should_not allow_value(nil).for(:pets).with_message("cannot be blank") }
    it { should_not allow_value(nil).for(:exclusive).with_message("cannot be blank") }
    it { should validate_presence_of(:utilities).on(:create) }
    it { should have_attached_file(:image) }
    it { should validate_attachment_content_type(:image).allowing("image/jpg", "image/png").rejecting("text/plain") }
  end

  describe "associations" do
    it { should have_many(:photos) }
    it { should belong_to(:listing_agent).class_name("Agent") }
    it { should belong_to(:sales_agent).class_name("Agent") }
    it { should belong_to(:office) }
    it { should have_many(:likes).class_name("Heart").dependent(:destroy) }
    it { should have_many(:interested_agents).through(:likes) }
  end

  describe "scopes" do
    context "other attributes" do
      before :each do
        @rental = create(:listing, rental: true)
        @sale = create(:listing, rental: false)
        @visible = create(:listing, private: false)
        @invisible = create(:listing, private: true)
        @special = create(:listing, featured: true)
        @commercial = create(:listing, residential: false)
        @no_thumbnail = create(:listing, image_updated_at: 3.years.ago)
        @listings = Listing.all
      end

      it "finds rentals" do
        expect(@listings.rentals).to include @rental
      end

      it "finds sales" do
        expect(@listings.sales).to include @sale
      end

      it "finds visible listings" do
        expect(@listings.visible).to include @visible
      end

      it "finds special listings" do
        expect(@listings.special).to include @special
      end

      it "finds listings with thumbnails" do
        expect(@listings.has_thumbnail).not_to include @no_thumbnail
      end
    end
  end

  describe "#thumb" do
    it "returns thumbnail url if photo is present" do
      listing = build_stubbed(:listing, primaryphoto: "/square/photo.jpg")

      expect(listing.thumb).to eq "/thumb/photo.jpg"
    end

    it "returns default url if photo is not present" do
      listing = build_stubbed(:listing, primaryphoto: "")

      expect(listing.thumb).to eq "https://s3.amazonaws.com/nooklyn-pro/thumb/1/forent.jpeg"
    end
  end
end
