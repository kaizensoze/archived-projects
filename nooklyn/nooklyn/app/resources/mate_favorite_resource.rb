require 'jsonapi/resource'

class MateFavoriteResource < JSONAPI::Resource
end

module Api
  module V1
    class MateFavoriteResource < JSONAPI::Resource
      model_name 'MatePost'

      attribute :id, format: :id
      attribute :first_name
      attribute :last_name
      attribute :price
      attribute :when
      attribute :image_url
      attribute :image
      attribute :description
      attribute :cats
      attribute :dogs
      attribute :hidden

      has_one :agent
      has_one :neighborhood

      delegate :first_name, :last_name, to: :user

      filters :id, :price, :when, :hidden

      def image_url
        @model.image.url(:large)
      end

      def self.records(options = {})
        context = options[:context]
        context[:requested_user].liked_mates
      end

      private

      def user
        model.agent
      end
    end
  end
end
