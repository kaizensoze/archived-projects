require 'jsonapi/resource'

class AgentResource < JSONAPI::Resource
end

module Api
  module V1
    class AgentResource < JSONAPI::Resource
      attribute :id, format: :id
      attribute :first_name
      attribute :last_name
      attribute :thumbnail
      attribute :profile_picture
      attribute :email
      attribute :phone
      attribute :password
      attribute :device_token
      attribute :facebook_authenticated
      attribute :on_probation
      attribute :suspended
      attribute :employee

      has_many :mate_posts, class_name: "Mate"

      def thumbnail
        @model.profile_picture.url(:medium)
      end

      def facebook_authenticated
        @model.provider == 'facebook'
      end

      def fetchable_fields()
        if context && context[:current_user] && @model.id == context[:current_user].id
          [:first_name, :last_name, :phone, :thumbnail, :profile_picture, :email, :facebook_authenticated, :on_probation, :suspended, :employee, :mate_posts]
        elsif @model.sales_agent_listings.count > 0
          [:first_name, :last_name, :phone, :thumbnail, :on_probation, :suspended, :employee]
        else
          [:first_name, :last_name, :thumbnail, :on_probation, :suspended, :employee]
        end
      end
    end
  end
end
