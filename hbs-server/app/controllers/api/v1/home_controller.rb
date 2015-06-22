class Api::V1::HomeController < ApplicationController
  skip_before_action :http_basic_authenticate
  skip_before_action :verify_authenticity_token
  before_action :restrict_access, except: [:send_verification_request, :check_verified]
  respond_to :json

  private
  def restrict_access
    authenticate_or_request_with_http_token do |token, options|
      token.present? && User.exists?(auth_token: token)
    end
  end

  public
  api :POST, '/send-verification-request', 'Send a verification email to the user.'
  param :email, String, desc: "The email of the user.", required: true
  param :device, String, desc: "The device of the user.", required: true

  def send_verification_request
    email = params[:email]
    device = params[:device]

    user = User.find_by(email: email)

    valid_user = !user.nil?

    json = {
        "success" => valid_user
    }

    # if valid user, set device id and send email confirmation
    if valid_user
      user.pending_device_id = device
      user.skip_reconfirmation!
      user.save!

      # automatically confirm for admin
      if user.email == 'admin@admin.com'
        user.confirmed_at = nil
        user.confirm!
      else
        user.confirmed_at = nil
        user.skip_reconfirmation!
        user.save!

        user.resend_confirmation_instructions
      end
    else
      json["errors"] = ["Thrive@HBS cannot be registered to this email address. Please contact thriveapp@hbs.edu if you have been excluded in error."]
    end

    render json: json
  end

  api :POST, '/check-verified', 'Check if the user has already verified.'
  param :email, String, desc: "The email of the user.", required: true
  param :device, String, desc: "The device of the user.", required: true

  def check_verified
    email = params[:email]
    device = params[:device]

    user = User.find_by(email: email, confirmed_device_id: device)

    valid_user = user.present?

    json = {
        "success" => valid_user
    }

    if valid_user
      json["auth_token"] = user.auth_token
      json["user_type"] = user.type
    else
      json["errors"] = ["User not verified. Try re-sending verification request."]
    end

    render json: json
  end

  api :GET, '/today', 'Get info for today and up to 4 days in the future.'

  def today
    # get user by auth token
    auth_token = ActionController::HttpAuthentication::Token.token_and_options(request)[0]
    user = User.find_by(auth_token: auth_token)

    # background images
    background_images_json = REDIS.get('background-images')
    if background_images_json.nil?
      background_images_json = BackgroundImage.where(active: true).order(:sort_order).to_json
      REDIS.set('background-images', background_images_json)
    end

    # announcements
    announcements_json = REDIS.get('announcements')
    if announcements_json.nil?
      announcements_json = Announcement.where(active: true).order(:sort_order).to_json
      REDIS.set('announcements', announcements_json)
    end

    json = {
        first_name: user.first_name,
        last_name: user.last_name,
        menus: Menu.where(date: Date.today..Date.today+4).order(:date),
        gym_schedules: GymSchedule.where(date: Date.today..Date.today+4).order(:date),
        background_images: JSON.parse(background_images_json),
        announcements: JSON.parse(announcements_json)
    }

    # poll

    selected_poll_id = Poll.find(1).active_id

    poll_json = REDIS.get("polls_#{selected_poll_id}")
    if poll_json.nil?

      uri = URI.parse('https://survey.qualtrics.com/WRAPI/ControlPanel/api.php')
      qualtrics_params = {
          :Request => 'getPollDefinition',
          :User => ENV['QUALTRICS_USERNAME'],
          :Token => ENV['QUALTRICS_APIKEY'],
          :Format => 'JSON',
          :Version => '2.4',
          :PollID => selected_poll_id
      }

      uri.query = URI.encode_www_form(qualtrics_params)
      poll_json = JSON.parse(Net::HTTP.get(uri))


      # manually include PollID
      poll_json['PollID'] = selected_poll_id

      poll_json = poll_json.to_json # make it string to save in redis

      REDIS.set("polls_#{selected_poll_id}", poll_json)
    end

    json['poll'] = JSON.parse(poll_json)

    respond_with(json)
  end

  api :POST, '/poll-submit', 'Submit a poll choice.'
  param :poll_id, String, desc: "The poll id.", required: true
  param :choice, String, desc: "The poll choice id to submit.", required: true

  def poll_submit
    poll_id = params[:poll_id]
    choice = params[:choice]

    selected_poll_id = Poll.find(1).active_id
    if poll_id != selected_poll_id
      json = {
          "success" => false,
          "errors" => ['Unable to submit poll choice.']
      }
      render json: json
      return
    end

    uri = URI.parse('https://survey.qualtrics.com/WRAPI/ControlPanel/api.php')
    qualtrics_params = {
        :Request => 'submitPollResults',
        :User => ENV['QUALTRICS_USERNAME'],
        :Token => ENV['QUALTRICS_APIKEY'],
        :Format => 'JSON',
        :Version => '2.4',
        :PollID => poll_id,
        :Results => poll_id + '_' + choice
    }
    uri.query = URI.encode_www_form(qualtrics_params)
    poll_json = JSON.parse(Net::HTTP.get(uri))

    submit_successful = poll_json["Meta"]["Status"] == "Success"

    json = {
        "success" => submit_successful
    }

    if !submit_successful
      json["errors"] = ['Unable to submit poll choice.']
    else
      del_poll_results(poll_id)
    end

    render json: json
  end

  api :GET, '/poll-results', 'Get poll results.'

  def poll_results
    poll_id = params[:poll_id]

    poll_results = get_poll_results(poll_id)
    if poll_results.nil?
      uri = URI.parse('https://survey.qualtrics.com/WRAPI/ControlPanel/api.php')
      qualtrics_params = {
          :Request => 'getPollResults',
          :User => ENV['QUALTRICS_USERNAME'],
          :Token => ENV['QUALTRICS_APIKEY'],
          :Format => 'JSON',
          :Version => '2.4',
          :PollID => poll_id
      }
      uri.query = URI.encode_www_form(qualtrics_params)
      poll_results = JSON.parse(Net::HTTP.get(uri))

      # There's a bug in version 1.0 of the app on handling a poll with empty results
      # or any result with 0 votes. Check if a request is coming from a v1.0 app and,
      # if so, adjust the results. A request from a v1.0 app will be missing the
      # server_no_adjust param.

      if !params.has_key?(:server_no_adjust)
        # get all possible choices and initialize to 0
        uri = URI.parse('https://survey.qualtrics.com/WRAPI/ControlPanel/api.php')
        qualtrics_params = {
            :Request => 'getPollDefinition',
            :User => ENV['QUALTRICS_USERNAME'],
            :Token => ENV['QUALTRICS_APIKEY'],
            :Format => 'JSON',
            :Version => '2.4',
            :PollID => poll_id
        }
        uri.query = URI.encode_www_form(qualtrics_params)
        poll_definition = JSON.parse(Net::HTTP.get(uri))

        choices = poll_definition["Result"]["Definition"]["Choices"]

        poll_results["Result"]["Payload"] = {} if poll_results["Result"]["Payload"].nil? || poll_results["Result"]["Payload"].empty?

        choices.each do |choice_id, choice_name|
          if poll_results["Result"]["Payload"][choice_id].nil? || poll_results["Result"]["Payload"][choice_id] == 0
            poll_results["Result"]["Payload"][choice_id] = 1
          end
        end
      end


      # extend json with errors if necessary
      if poll_results["Meta"]["Status"] != "Success"
        poll_results["errors"] = ['Unable to get poll results.']
        poll_results = poll_results.to_json
      else
        poll_results = poll_results.to_json
      end
      set_poll_results poll_id, poll_results
    end
    respond_with(JSON.parse(poll_results))
  end

  api :GET, '/help-now', 'Get Help Now evergreen content.'

  def help_now
    help_now_json = REDIS.get('help-now')
    if help_now_json.nil?
      help_now_json = HelpNowItem.order(:sort_order).to_json
      REDIS.set('help-now', help_now_json)
    end

    respond_with(JSON.parse(help_now_json))
  end

  api :GET, '/who-to-call', 'Get Who To Call evergreen content.'

  def who_to_call
    who_to_call_json = REDIS.get('who-to-call')
    if who_to_call_json.nil?
      json = []

      who_to_call_items = WhoToCallItem.joins(:who_to_call_subject).order('who_to_call_subjects.sort_order', :sort_order)
      who_to_call_items.each do |who_to_call_item|
        dict = who_to_call_item.attributes
        dict['subject'] = who_to_call_item.who_to_call_subject.subject
        json.push(dict)
      end

      who_to_call_json = json.to_json
      REDIS.set('who-to-call', who_to_call_json)
    end

    respond_to do |format|
      format.json do
        render :json => JSON.parse(who_to_call_json)
        # render :json => who_to_call_items.to_json(:include => { :who_to_call_subject => { :only => [:subject, :sort_order] } })
      end
    end
  end

  api :GET, '/did-you-know', 'Get Did You Know evergreen content'

  def did_you_know
    did_you_know_json = REDIS.get('did-you-know')
    if did_you_know_json.nil?
      json = []

      did_you_know_items = DidYouKnowItem.joins(:did_you_know_subject).order('did_you_know_subjects.sort_order', :sort_order)
      did_you_know_items.each do |did_you_know_item|
        dict = did_you_know_item.attributes
        dict['subject'] = did_you_know_item.did_you_know_subject.subject
        json.push(dict)
      end

      did_you_know_json = json.to_json
      REDIS.set('did-you-know', did_you_know_json)
    end

    respond_to do |format|
      format.json do
        render :json => JSON.parse(did_you_know_json)
        # render :json => did_you_know_items.to_json(:include => { :did_you_know_subject => { :only => [:subject, :sort_order] } })
      end
    end
  end

  private

  def get_poll_results poll_id
    last_cache_time = REDIS.get("poll_results_#{poll_id}_time")
    cache_time = Time.zone.parse last_cache_time || Time.zone.now.to_s
    if 1.hour.ago > cache_time
      del_poll_results(poll_id)
      poll_results = nil
    else
      poll_results = REDIS.get("poll_results_#{poll_id}")
    end
    poll_results
  end

  def del_poll_results poll_id
    REDIS.del("poll_results_#{poll_id}_time")
    REDIS.del("poll_results_#{poll_id}")
  end

  def set_poll_results poll_id, poll_results
    REDIS.set("poll_results_#{poll_id}_time", Time.zone.now.to_s)
    REDIS.set("poll_results_#{poll_id}", poll_results)
  end
end
