require 'jsonapi/resource'

class ConversationResource < JSONAPI::Resource
end

module Api
  module V1
    class ConversationResource < JSONAPI::Resource
      attribute :id, format: :id
      attribute :created_at
      attribute :updated_at
      attribute :context_url
      attribute :participants

      # has_many :participants, class_name: "ConversationParticipant"
      has_many :participating_agents, class_name: "Agent"
      has_many :messages, class_name: "ConversationMessage"

      def self.records(options = {})
        context = options[:context]
        AgentQueries::ConversationList.new(context[:current_user]).list
      end
    end
  end
end
