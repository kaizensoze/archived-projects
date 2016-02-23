require 'jsonapi/resource'

class RegionResource < JSONAPI::Resource
end

class Api::V1::RegionResource < JSONAPI::Resource
  attribute :id, format: :id
  attribute :name
  attribute :image
  attribute :featured
  attribute :latitude
  attribute :longitude

  filters :id, :featured
end
