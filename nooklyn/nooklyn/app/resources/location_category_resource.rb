require 'jsonapi/resource'

class LocationCategoryResource < JSONAPI::Resource
end

class Api::V1::LocationCategoryResource < JSONAPI::Resource
  attribute :id, format: :id
  attribute :name
  attribute :featured
  attribute :image_url

  filters :id

  def image_url
    @model.image.url
  end
end
