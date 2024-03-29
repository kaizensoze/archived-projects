describe RoomPost do
  describe "validations" do
    it { should validate_presence_of(:price) }
    it { should validate_numericality_of(:price) }
    it { should validate_presence_of(:description) }
    it { should validate_presence_of(:when) }
    it { should validate_presence_of(:neighborhood) }
    it { should validate_presence_of(:latitude) }
    it { should validate_presence_of(:longitude) }
    it { should validate_uniqueness_of(:agent_id).with_message(": You can't post more than once.") }
    it { should have_attached_file(:image) }
    it { should validate_attachment_presence(:image) }
    it { should validate_attachment_content_type(:image).allowing("image/jpg").rejecting("text/plain") }
  end

  describe "associations" do
    it { should have_many(:likes).class_name("RoomPostLike").dependent(:destroy) }
    it { should have_many(:interested_agents).through(:likes) }
    it { should have_many(:rooms).dependent(:destroy) }
  end

  describe "scopes" do
    it "finds visible posts" do
      visible = create(:room_post, hidden: false)
      expect(RoomPost.visible).to include visible
    end

    it "finds upcoming posts" do
      upcoming = create(:room_post, :when => 3.months.from_now)
      expect(RoomPost.upcoming).to include upcoming
    end
  end
end
