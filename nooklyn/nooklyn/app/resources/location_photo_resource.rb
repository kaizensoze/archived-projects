require 'jsonapi/resource'

class LocationPhotoResource < JSONAPI::Resource
end

class Api::V1::LocationPhotoResource < JSONAPI::Resource
  attribute :thumbnail
  attribute :image
  attribute :caption

  def thumbnail
    @model.image.url(:thumb)
  end

  def image
    @model.image.url(:large)
  end
end
