json.listings @listings do |listing|
  json.id listing.id
  json.bedrooms listing.bedrooms
  json.bathrooms listing.bathrooms
  json.price number_to_currency(listing.price, precision: 0)
  json.photo_url listing.image.url(:xlarge)
  json.medium_photo_url listing.image.url(:medium)
  json.thumbnail_url listing.image.url(:thumb)
  json.latitude listing.latitude
  json.longitude listing.longitude
  json.status listing.status
  json.residential listing.residential
  json.rental listing.rental
  json.description listing.description
  json.amenities listing.amenities
  json.subway_line_url listing.subway_line_url
  json.subway_line listing.subway_line
  json.station listing.station
  json.neighborhood_id listing.neighborhood.id
  json.sales_agent_id listing.sales_agent.id
  if @agent && @agent.employee?
    json.address listing.address
    json.apartment listing.apartment
    json.access listing.access
    json.listing_agent_name listing.listing_agent.name
    json.term listing.term
    json.date_available listing.date_available
  end
end
