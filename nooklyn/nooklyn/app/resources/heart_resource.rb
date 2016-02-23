require 'jsonapi/resource'

class HeartResource < JSONAPI::Resource
end

module Api
  module V1
    class HeartResource < JSONAPI::Resource
      attribute :id, format: :id
      attribute :agent_id
      attribute :listing_id

      filters :agent_id, :listing_id

      def self.records(options = {})
        context = options[:context]
        context[:current_user].hearts
      end
    end
  end
end
