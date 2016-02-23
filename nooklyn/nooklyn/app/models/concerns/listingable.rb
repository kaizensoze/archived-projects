module Listingable
  extend ActiveSupport::Concern

  included do
    include Elasticsearch::Model
    include Elasticsearch::Model::Callbacks

    settings index: { number_of_shards: 1, number_of_replicas: 1 } do
      mapping do
        indexes :lon_lat, type: 'geo_point'
      end
    end

    def as_indexed_json(options={})
      as_json(
        only: [:id, :title, :description, :address, :price,
               :bedrooms, :bathrooms, :full_address,
               :amenities, :status, :fee, :apartment, :neighborhood_id,
               :longitude, :latitude, :access, :pets, :utilities, :residential, :exclusive
               ],
        methods: [:primary_thumbnail, :searchable_description, :lon_lat]
      )
    end

    def lon_lat
      [longitude, latitude]
    end

    def self.search(query)
      __elasticsearch__.search(
        {
          size: 50,
          query: {
            multi_match: {
              query: query,
              fields: ['amenities', 'searchable_description^10', 'address']
            }
          }
        }
      )
    end

    def self.geo_search(radius: 1, latitude:, longitude:, residential_only: false)
      if residential_only
        listing_ids = Listing.available.residential.visible.has_thumbnail.pluck(:id)
      else
        listing_ids = Listing.available.visible.has_thumbnail.pluck(:id)
      end

       __elasticsearch__.search({
         size: 15,
         query: {
           filtered: {
             filter: {
               and: [
                 {
                   terms: {
                     id: listing_ids
                   },
                 },
                 {
                   geo_distance: {
                     distance: "#{radius}mi",
                     lon_lat: {
                       lat: latitude,
                       lon: longitude
                     }
                   }
                 }
               ]
             }
           }
         },
         sort: [{
           _geo_distance: {
             lon_lat: {
               lat: latitude,
               lon: longitude
             },
             order: 'asc',
             unit: 'mi',
             distance_type: 'plane'
           }
         }]
       })
    end
  end
end
