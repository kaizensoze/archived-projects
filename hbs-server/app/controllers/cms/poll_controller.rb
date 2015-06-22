class Cms::PollController < ApplicationController
  before_action :authenticate_admin_user!
  
  layout 'cms'
  
  def index
    uri = URI.parse('https://survey.qualtrics.com/WRAPI/ControlPanel/api.php')
    qualtrics_params = {
      :Request => 'getPolls',
      :User => ENV['QUALTRICS_USERNAME'],
      :Token => ENV['QUALTRICS_APIKEY'],
      :Format => 'JSON',
      :Version => '2.4'
    }
    uri.query = URI.encode_www_form(qualtrics_params)
    response = JSON.parse(Net::HTTP.get(uri))
    polls = response['Result']
    polls = polls.sort { |x,y| -( x["LastModified"] <=> y["LastModified"] ) }
    
    @polls = {}
    polls.each do |poll|
      poll_id = poll['PollID']
      poll_name = poll['Name']
      @polls[poll_name] = poll_id
    end

    @poll = Poll.find(1)
  end

  def save
    @poll = Poll.find(1)
    @poll.update(active_id: params[:poll_id])
    
    flash[:notice] = "Active poll updated."
    redirect_to cms_poll_index_path
  end
end
