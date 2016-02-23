describe JobApplication do
  describe "#validations" do
    it { should validate_presence_of(:full_name) }
    it { should validate_presence_of(:email) }
    it { should validate_presence_of(:current_company) }
    it { should validate_presence_of(:position) }
    it { should validate_inclusion_of(:position).in_array(JobApplication::POSITIONS).with_message('must selected from the available choices') }
    it { should have_attached_file(:resume) }
    it { should validate_attachment_presence(:resume) }
    it { should validate_attachment_content_type(:resume).allowing("application/pdf").rejecting("text/plain")}
  end

  describe "#positions" do
    it "returns the positions array" do
      expect(JobApplication.positions).to eq JobApplication::POSITIONS
    end
  end
end
