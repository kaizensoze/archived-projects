module Matrix
  class PagesController < MatrixBaseController

    def agent_guide
    end

    def documents
    end

    def recruiting_guide
      if current_agent.employer?
      else
        redirect_to root_path, notice: 'You are not authorized.'
      end
    end

    def statistics
      # Agents
      @users = Agent.all
      @users_day = Agent.all.where('created_at >= ? AND created_at <= ?', Time.zone.now.beginning_of_day, Time.zone.now.end_of_day)
      @users_week = Agent.all.where('created_at >= ? AND created_at <= ?', Time.zone.now.beginning_of_week, Time.zone.now.end_of_week)
      @users_month = Agent.all.where('created_at >= ? AND created_at <= ?', Time.zone.now.beginning_of_month, Time.zone.now.end_of_month)
      @user_stats = user_months.map do |(start_month, end_month)|
        month_year = start_month.strftime('%B %Y')
        users_for_month = Agent.all
          .where('created_at >= ? AND created_at <= ?', start_month, end_month)

        [month_year, users_for_month]
      end
      # Mate Posts
      @mates = MatePost.all
      @mates_day = MatePost.all.where('created_at >= ? AND created_at <= ?', Time.zone.now.beginning_of_day, Time.zone.now.end_of_day)
      @mates_week = MatePost.all.where('created_at >= ? AND created_at <= ?', Time.zone.now.beginning_of_week, Time.zone.now.end_of_week)
      @mates_month = MatePost.all.where('created_at >= ? AND created_at <= ?', Time.zone.now.beginning_of_month, Time.zone.now.end_of_month)
      @mate_stats = mate_months.map do |(start_month, end_month)|
        month_year = start_month.strftime('%B %Y')
        mates_for_month = MatePost.all
          .where('created_at >= ? AND created_at <= ?', start_month, end_month)

        [month_year, mates_for_month]
      end


      # Messages
      @messages = ConversationMessage.all
      @messages_day = ConversationMessage.all.where('created_at >= ? AND created_at <= ?', Time.zone.now.beginning_of_day, Time.zone.now.end_of_day)
      @messages_week = ConversationMessage.all.where('created_at >= ? AND created_at <= ?', Time.zone.now.beginning_of_week, Time.zone.now.end_of_week)
      @messages_month = ConversationMessage.all.where('created_at >= ? AND created_at <= ?', Time.zone.now.beginning_of_month, Time.zone.now.end_of_month)

      @message_stats = message_months.map do |(start_month, end_month)|
        month_year = start_month.strftime('%B %Y')
        messages_for_month = ConversationMessage.all
          .where('created_at >= ? AND created_at <= ?', start_month, end_month)

        [month_year, messages_for_month]
      end


      @deposits = Deposit.all
      @deposits_day = Deposit.all.where('created_at >= ? AND created_at <= ?', Time.zone.now.beginning_of_day, Time.zone.now.end_of_day)
      @deposits_week = Deposit.all.where('created_at >= ? AND created_at <= ?', Time.zone.now.beginning_of_week, Time.zone.now.end_of_week)
      @deposits_month = Deposit.all.where('created_at >= ? AND created_at <= ?', Time.zone.now.beginning_of_month, Time.zone.now.end_of_month)

      @deposit_stats = deposit_months.map do |(start_month, end_month)|
        month_year = start_month.strftime('%B %Y')
        deposits_for_month = Deposit.all
          .where('created_at >= ? AND created_at <= ?', start_month, end_month)

        [month_year, deposits_for_month]
      end



      # Photos
      @photos = Photo.all
      @photos_day = Photo.all.where('created_at >= ? AND created_at <= ?', Time.zone.now.beginning_of_day, Time.zone.now.end_of_day)
      @photos_week = Photo.all.where('created_at >= ? AND created_at <= ?', Time.zone.now.beginning_of_week, Time.zone.now.end_of_week)
      @photos_month = Photo.all.where('created_at >= ? AND created_at <= ?', Time.zone.now.beginning_of_month, Time.zone.now.end_of_month)

      # Locations
      @locations = Location.all
      @locations_sf = Location.joins(:neighborhood).where(neighborhoods: { region_id: [4] })
      @locations_nyc = Location.joins(:neighborhood).where(neighborhoods: { region_id: [1, 2, 3] })

      # Neighborhoods
      @neighborhoods = Neighborhood.all

      # Listings
      @listings = Listing.all
      @available_listings = Listing.available
      @exclusive_listings_available = Listing.available.exclusive
      @exclusive_listings_total = Listing.exclusive
      @popular = Listing.residential
                        .available
                        .page(params[:page])
                        .per(25)
                        .order('hearts_count DESC')
      @newest = Listing.residential
                       .available
                       .page(params[:page])
                       .per(25)
                       .order('created_at DESC')

      # Leads
      @leads = Lead.all

      # Agents
      @employees = Agent.employees
      @employees_month = Agent.employees.where('created_at >= ? AND created_at <= ?', Time.zone.now.beginning_of_month, Time.zone.now.end_of_month)
      @employees_year = Agent.employees.where('created_at >= ? AND created_at <= ?', Time.zone.now.beginning_of_year, Time.zone.now.end_of_year)
      @agent_deposit_stats = AgentDepositStat.includes(:agent)
        .current_month
        .ranked

      # Likes
      @liked_listings = Heart.all
      @mate_likes = MatePostLike.all
      @room_likes = RoomPostLike.all
      @location_likes = LocationLike.all
    end

    private

    def user_months
      current_date = USERS_LAUNCH_DATE
      months = Array.new

      while current_date < Time.zone.now
        months << [current_date.beginning_of_month, current_date.end_of_month]
        current_date = current_date.next_month
      end

      months
    end

    def mate_months
      current_date = MATES_LAUNCH_DATE
      months = Array.new

      while current_date < Time.zone.now
        months << [current_date.beginning_of_month, current_date.end_of_month]
        current_date = current_date.next_month
      end

      months
    end

    def deposit_months
      current_date = DEPOSITS_LAUNCH_DATE
      months = Array.new

      while current_date < Time.zone.now
        months << [current_date.beginning_of_month, current_date.end_of_month]
        current_date = current_date.next_month
      end

      months
    end

    def message_months
      current_date = MESSAGES_LAUNCH_DATE
      months = Array.new

      while current_date < Time.zone.now
        months << [current_date.beginning_of_month, current_date.end_of_month]
        current_date = current_date.next_month
      end

      months
    end
  end
end
