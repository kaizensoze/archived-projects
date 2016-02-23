class ListingsCollectionMembership < ActiveRecord::Base
  belongs_to :listing
  belongs_to :listings_collection
end
