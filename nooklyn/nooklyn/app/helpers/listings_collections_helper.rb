module ListingsCollectionsHelper
  def random_listing_image(listings_collection)
    random_listing = listings_collection.listings.reject { |e| e.image.blank? }.sample
    random_listing.try(:primary_thumbnail) || "missing.png"
  end
end