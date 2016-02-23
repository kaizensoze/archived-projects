describe "listings collections", type: :request do
  before :each do
    @agent = create(:agent)
    @my_collections = create_list(:listings_collection, 2, agent: @agent)
    @not_mine = create(:listings_collection)
  end

  context "when agent is signed in" do
    it "returns only the agent's collections" do
      allow_any_instance_of(Api::V1::ListingsCollectionsController).to receive(:current_agent).and_return(@agent)
      get "/api/v1/listings-collections", format: :json
      returned_collections = JSON.parse(response.body)["data"].map{|c| c["id"].to_i }

      expect(returned_collections).to include @my_collections[0].id
      expect(returned_collections).to include @my_collections[1].id
      expect(returned_collections).not_to include @not_mine.id
    end
  end

  context "when agent is not signed in" do
    it "returns all collections" do
      get "/api/v1/listings-collections", format: :json
      returned_collections = JSON.parse(response.body)["data"].map{|c| c["id"].to_i }

      expect(returned_collections).to include @my_collections[0].id
      expect(returned_collections).to include @my_collections[1].id
      expect(returned_collections).to include @not_mine.id
    end
  end
end
