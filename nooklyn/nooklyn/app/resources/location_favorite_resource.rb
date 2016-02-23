require 'jsonapi/resource'

class LocationFavoriteResource < JSONAPI::Resource
end

module Api
  module V1
    class LocationFavoriteResource < JSONAPI::Resource
      model_name 'Location'

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

      has_one :neighborhood

      filters :id

      def self.records(options = {})
        context = options[:context]
        context[:requested_user].liked_locations
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
  end
end
