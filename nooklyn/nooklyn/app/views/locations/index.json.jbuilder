json.locations @locations do |location|
  json.id location.id
  json.name location.name
  json.photo_url location.image.url(:xlarge)
  json.medium_photo_url location.image.url(:large)
  json.thumbnail_url location.image.url(:medium)
  json.latitude location.latitude
  json.longitude location.longitude
  json.address location.address
  json.description location.description
  json.location_category location.location_category
end
