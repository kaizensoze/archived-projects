require 'jsonapi/resource'

class MatePostLikeResource < JSONAPI::Resource
end

module Api
  module V1
    class MatePostLikeResource < JSONAPI::Resource
      attribute :id, format: :id
      attribute :agent_id
      attribute :mate_post_id

      filters :agent_id, :mate_post_id

      def self.records(options = {})
        context = options[:context]
        context[:current_user].mate_post_likes
      end
    end
  end
end
