require 'jsonapi/resource'

class LocationLikeResource < JSONAPI::Resource
end

module Api
  module V1
    class LocationLikeResource < JSONAPI::Resource
      attribute :id, format: :id
      attribute :agent_id
      attribute :location_id

      filters :agent_id, :location_id

      def self.records(options = {})
        context = options[:context]
        context[:current_user].location_likes
      end
    end
  end
end
