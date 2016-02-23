require 'jsonapi/resource'

class IgnoredListingResource < JSONAPI::Resource
end

module Api
  module V1
    class IgnoredListingResource < JSONAPI::Resource
      model_name 'Listing'

      attribute :id, format: :id
      attribute :bathrooms
      attribute :bedrooms
      attribute :featured
      attribute :price
      attribute :image
      attribute :medium_image
      attribute :primary_thumbnail
      attribute :status
      attribute :private
      attribute :image_updated_at
      attribute :hearts_count
      attribute :updated_at
      attribute :latitude
      attribute :longitude
      attribute :residential
      attribute :rental
      attribute :description
      attribute :amenities
      attribute :subway_line_url
      attribute :subway_line
      attribute :station

      # for employee eyes only
      attribute :address
      attribute :apartment
      attribute :access
      attribute :listing_agent_name
      attribute :term
      attribute :date_available

      has_one :neighborhood
      has_one :sales_agent, class_name: "Agent"
      has_many :photos

      filters :id, :bathrooms, :bedrooms, :private, :status, :residential

      def self.records(options = {})
        context = options[:context]
        context[:current_user].ignored_listings
      end

      def image
        @model.image.url(:xlarge)
      end

      def medium_image
        @model.image.url(:medium)
      end

      def primary_thumbnail
        @model.image.url(:medium) # TODO: change back to thumb after 1.4.3 app release
      end

      def listing_agent_name
        @model.listing_agent.name
      end

      def fetchable_fields()
        if context && context[:current_user] && context[:current_user].employee?
          [
            :id, :bathrooms, :bedrooms, :featured, :price, :image,
            :medium_image, :primary_thumbnail, :status, :private,
            :image_updated_at, :hearts_count, :updated_at, :latitude,
            :longitude, :residential, :rental, :description, :amenities,
            :subway_line_url, :subway_line, :station, :neighborhood,
            :sales_agent, :photos, :address, :apartment, :access, :listing_agent_name,
            :term, :date_available
          ]
        else
          [
            :id, :bathrooms, :bedrooms, :featured, :price, :image,
            :medium_image, :primary_thumbnail, :status, :private,
            :image_updated_at, :hearts_count, :updated_at, :latitude,
            :longitude, :residential, :rental, :description, :amenities,
            :subway_line_url, :subway_line, :station, :neighborhood,
            :sales_agent, :photos
          ]
        end
      end
    end
  end
end
