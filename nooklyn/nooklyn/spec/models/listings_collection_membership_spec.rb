describe ListingsCollectionMembership do
  it "validates uniqueness on listing_id and listings_collection_id" do
    collection = create(:listings_collection)
    listing1 = collection.listings[0]
    valid_membership = build(:listings_collection_membership, listings_collection: collection)
    invalid_membership = build(:listings_collection_membership, listing: listing1, listings_collection: collection)

    expect(valid_membership).to be_valid
    expect(invalid_membership).not_to be_valid
  end
end
