module ListingsHelper
  def cache_key_for_listings
    count          = Listing.count
    max_updated_at = Listing.maximum(:updated_at).try(:utc).try(:to_s, :number)
    action = request[:action]
    "listings/#{action}-#{count}-#{max_updated_at}"
  end

  def cache_key_for_matrix
    count          = Listing.count
    max_updated_at = Listing.maximum(:updated_at).try(:utc).try(:to_s, :number)
    action = request[:action]
    "matrix/#{action}-#{count}-#{max_updated_at}"
  end
end
