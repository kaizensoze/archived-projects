module MessageCommands
  class CreateConversation

    def initialize(participants, options = nil)
      options = Hash(options)

      @context_url = options.fetch(:context_url) { '' }
      @initial_message = options.fetch(:message) { :message_not_supplied }
      @participants = format_participants(participants)
    end

    def execute
      Conversation.transaction do
        create_conversation
        add_participants
        create_initial_message
      end

      conversation
    end

    private

    def add_participants
      AddParticipants.new(conversation, participants).execute
    end

    def create_conversation
      @conversation = Conversation.create(context_url: context_url)
    end

    def create_initial_message
      initial_message.save!
    end

    def format_participants(participants)
      participants.map do |participant|

        case participant
        when Agent
          participant
        when String
          Agent.find_by(email: participant) || (raise ArgumentError.new)
        else
          raise ArgumentError.new("Received participant of type: #{participant.class} for context_url: #{context_url}")
        end
      end
    end

    attr_reader :conversation, :context_url, :initial_message, :participants
  end
end
