module Locationable
  extend ActiveSupport::Concern

  included do
    include Elasticsearch::Model
    include Elasticsearch::Model::Callbacks

    settings index: { number_of_shards: 1, number_of_replicas: 1 } do
      mapping do
        indexes :lon_lat, type: 'geo_point'
      end
    end

    def as_indexed_json(options = {})
      {
        lon_lat: lon_lat
      }
    end

    def lon_lat
      [longitude, latitude]
    end

    def self.geo_search(radius: 1, latitude:, longitude:)
       __elasticsearch__.search({
         size: 20,
         query: {
           filtered: {
             filter: {
               geo_distance: {
                 distance: "#{radius}mi",
                 lon_lat: {
                   lat: latitude,
                   lon: longitude
                 }
               }
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
