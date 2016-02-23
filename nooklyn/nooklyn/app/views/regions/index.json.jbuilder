json.array!(@regions) do |region|
  json.extract! region, :id, :name, :neighborhood_id, :featured
  json.url region_url(region, format: :json)
end
