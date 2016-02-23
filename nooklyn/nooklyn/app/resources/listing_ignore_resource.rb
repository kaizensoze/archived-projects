require 'jsonapi/resource'

class ListingIgnoreResource < JSONAPI::Resource
end

module Api
  module V1
    class ListingIgnoreResource < JSONAPI::Resource
      attribute :id, format: :id
      attribute :agent_id
      attribute :listing_id

      filters :agent_id, :listing_id

      def self.records(options = {})
        context = options[:context]
        context[:current_user].listing_ignores
      end
    end
  end
end
