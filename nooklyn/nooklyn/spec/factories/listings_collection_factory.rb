FactoryGirl.define do
  factory :listings_collection do
    agent
    sequence(:name) {|n| "Collection #{n}" }

    after(:create) do |collection|
      create_list(:listings_collection_membership, 2, listings_collection: collection)
    end
  end

  factory :listings_collection_membership do
    listings_collection
    listing
  end
end
