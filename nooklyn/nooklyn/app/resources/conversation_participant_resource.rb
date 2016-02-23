require 'jsonapi/resource'

class ConversationParticipantResource < JSONAPI::Resource
end

module Api
  module V1
    class ConversationParticipantResource < JSONAPI::Resource
      attribute :id, format: :id
      attribute :archived_at
      attribute :unread_messages

      has_one :agent
      has_one :conversation
    end
  end
end
