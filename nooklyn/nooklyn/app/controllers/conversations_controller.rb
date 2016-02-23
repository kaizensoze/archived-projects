class ConversationsController < ApplicationController
  layout 'nklyn-pages'

  before_action :check_authorized_participant, only: [:show]

  def index
    if !agent_signed_in?
      redirect_to login_path, notice: 'Please login to check your messages.'
    else
      @conversations = AgentQueries::ConversationList.new(current_agent, archived: false).list
    end
  end

  def show
    if !agent_signed_in?
    redirect_to login_path, notice: 'Please login to check your messages.'
    else
    @conversation = Conversation.find(params[:id])
    MessageCommands::MarkMessageRead.new(@conversation, current_agent).execute
    end
  end


  def create
    # Fixes bug where logged out session would throw exception
    if current_agent
      recipients = Agent.where(id: params[:conversation][:recipient_id])
      recipients << current_agent

      message = ConversationMessage.new(message_params).tap do |cm|
        cm.agent = current_agent
      end

      conversation_command = MessageCommands::CreateConversation.new(recipients,
                                                                     context_url: params[:conversation][:context_url],
                                                                     message: message
                                                                     )
      conversation = conversation_command.execute


      message_command = MessageCommands::AddMessage.new(message, conversation)
      message_command.execute

      if message.persisted?
        redirect_to :back, notice: 'Message was sent.'
      else
        redirect_to :back, notice: 'Sorry, there was an error sending your message.'
      end
    else
      redirect_to login_path, notice: 'You must be logged-in to send a message.'
    end
  end

  def archive
    if !agent_signed_in?
      redirect_to login_path, notice: 'Please login to check your messages.'
    else
      @conversations = AgentQueries::ConversationList.new(current_agent, archived: true).list
      render :index
    end
  end

  def mark_as_archived
    conversation = Conversation.find(params[:id])
    command = MessageCommands::ArchiveConversation.new(conversation, current_agent)

    command.on(:success) do
      redirect_to conversations_path, notice: 'Message was archived!'
    end

    command.on(:failure) do
      redirect_to conversation_path(conversation), notice: 'We were unable to archive this message =['
    end

    command.execute
  end

  def mark_as_unarchived
    conversation = Conversation.find(params[:id])
    command = MessageCommands::UnarchiveConversation.new(conversation, current_agent)

    command.on(:success) do
      redirect_to archive_conversations_path, notice: 'Message was return to your inbox!'
    end

    command.on(:failure) do
      redirect_to conversation_path(conversation), notice: 'We were unable to move this message back to your inbox =['
    end

    command.execute
  end

  private

  def check_authorized_participant
    if agent_signed_in?
      is_authorized = ConversationParticipant.where(conversation_id: params[:id])
        .map(&:agent_id)
        .include?(current_agent.id)

      # Allow super admins to view any conversation
      is_authorized = is_authorized || current_agent.super_admin?
    else
    end

    unless is_authorized
      raise CanCan::AccessDenied
    end
  end

  def message_params
    {
      ip_address: request.remote_ip,
      user_agent: request.env["HTTP_USER_AGENT"],
      message: params[:conversation][:message]
    }
  end
end
