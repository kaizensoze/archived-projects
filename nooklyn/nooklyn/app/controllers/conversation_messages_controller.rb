class ConversationMessagesController < ApplicationController

  def create

    message_params = conversation_message_params.merge({
      ip_address: request.remote_ip,
      user_agent: request.env["HTTP_USER_AGENT"]
    })

    message = ConversationMessage.new(message_params).tap do |cm|
      cm.agent = current_agent
    end

    command = MessageCommands::AddMessage.new(message)
    command.execute

    if message.persisted?
      redirect_to :back, notice: 'Message was sent.'
    else
      redirect_to :back, notice: 'Sorry, there was an error sending your message.'
    end
  end

  private

  def conversation_message_params
    params.require(:conversation_message).permit(:message, :conversation_id)
  end
end
