class LeadUpdatesController < ApplicationController
  def create
    update_params = lead_update_params.merge({
      ip_address: request.remote_ip,
      user_agent: request.env["HTTP_USER_AGENT"],
      agent_id: current_agent.id
    })

    @lead = Lead.find(params[:lead_id])
    @lead_update = @lead.updates.build(update_params)

    if @lead_update.save
      redirect_to [@lead], notice: 'Comment Successfully Posted'
    else
      redirect_to [@lead], error: 'Error Posting Comment'
    end
  end

  private

  def lead_update_params
    params.require(:lead_update)
          .permit(:agent_id, :ip_address, :lead_id, :message, :user_agent)
  end
end
