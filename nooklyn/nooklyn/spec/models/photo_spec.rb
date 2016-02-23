describe Photo do
  it { should belong_to :listing }
  it { should have_attached_file :image }
  it { should validate_attachment_presence :image }
  it { should validate_attachment_content_type(:image).
              allowing('image/jpeg', 'image/jpg', 'image/png', 'image/gif').
              rejecting('application/pdf') }

  describe "#to_jq_upload" do
    it "returns a hash of attributes" do
      photo = create(:photo, image_file_size: 10)
      result = photo.to_jq_upload

      expect(result["name"]).to eq "photo.jpg"
      expect(result["size"]).to eq 10
      expect(result["url"]).to eq "https://s3.amazonaws.com/nooklyn-test/square/#{photo.id}/photo.jpg"
      expect(result["delete_url"]).to eq "/photos/#{photo.id}"
      expect(result["delete_type"]).to eq "DELETE"
    end
  end
end
