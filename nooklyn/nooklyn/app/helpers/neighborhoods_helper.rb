module NeighborhoodsHelper
  def cache_key_for_neighborhood_listings
    count          = Listing.count
    max_updated_at = Listing.maximum(:updated_at).try(:utc).try(:to_s, :number)
    action = "#{request[:action]}-#{request.params[:id]}"
    "listings/#{action}-#{count}-#{max_updated_at}"
  end
end
