class ListingsCollectionMembership < ActiveRecord::Base
  belongs_to :listing
  belongs_to :listings_collection

  validates :listing_id, uniqueness: { scope: :listings_collection_id }
end
