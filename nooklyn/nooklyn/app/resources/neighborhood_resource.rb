require 'jsonapi/resource'

class NeighborhoodResource < JSONAPI::Resource
end

class Api::V1::NeighborhoodResource < JSONAPI::Resource
  attribute :id, format: :id
  attribute :name
  attribute :image
  attribute :featured
  attribute :latitude
  attribute :longitude
  attribute :active_listing_count
  attribute :location_category_count

  has_one :region
  has_many :location_categories

  filters :id, :featured

  def image
    @model.image.url(:large)
  end

  def active_listing_count
    @model.listings.available.count
  end

  def location_category_count
    @model.location_categories.count
  end
end
