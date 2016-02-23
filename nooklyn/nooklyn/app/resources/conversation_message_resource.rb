require 'jsonapi/resource'

class ConversationMessageResource < JSONAPI::Resource
end

module Api
  module V1
    class ConversationMessageResource < JSONAPI::Resource
      attribute :id, format: :id
      attribute :message
      attribute :ip_address
      attribute :user_agent
      attribute :created_at
      attribute :updated_at

      has_one :conversation
      has_one :agent
    end
  end
end
