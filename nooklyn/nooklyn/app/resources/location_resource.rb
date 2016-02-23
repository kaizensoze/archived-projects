require 'jsonapi/resource'

class LocationResource < JSONAPI::Resource
end

class Api::V1::LocationResource < JSONAPI::Resource
  attribute :id, format: :id
  attribute :name
  attribute :description
  attribute :latitude
  attribute :longitude
  attribute :address
  attribute :website
  attribute :facebook_url
  attribute :delivery_website
  attribute :yelp_url
  attribute :phone_number
  attribute :image
  attribute :medium_image
  attribute :thumbnail
  attribute :featured

  has_one :neighborhood
  has_one :location_category
  has_many :photos, class_name: "LocationPhoto"

  filters :id, :neighborhood_id, :location_category_id, :region_id, :featured

  def self.apply_filter(records, filter, value, options)
    case filter
    when :region_id
      Location.joins(:neighborhood).where(neighborhoods: { region_id: [value] })
    else
      return super(records, filter, value)
    end
  end

  def image
    @model.image.url(:xlarge)
  end

  def medium_image
    @model.image.url(:large)
  end

  def thumbnail
    @model.image.url(:medium)
  end
end
