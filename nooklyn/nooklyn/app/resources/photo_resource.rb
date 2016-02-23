require 'jsonapi/resource'

class PhotoResource < JSONAPI::Resource
end

class Api::V1::PhotoResource < JSONAPI::Resource
  attribute :thumbnail
  attribute :image
  attribute :featured

  def thumbnail
    @model.image.url(:square)
  end

  def image
    @model.image.url(:large)
  end
end
