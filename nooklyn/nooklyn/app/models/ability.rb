class Ability
  include CanCan::Ability

  def initialize(agent)
    agent ||= Agent.new # guest user (not logged in)

    if agent.super_admin?
      can :manage, :all
    else
      can [:read, :rentals, :sales, :commercial, :_listings], Listing
      can [:read, :rooms, :locations, :_listings], Neighborhood
      can :create, [Lead, Feedback, JobApplication]
      can :read, [Agent,
                  RoomPost,
                  Guide,
                  GuideStory,
                  Location,
                  LocationCategory,
                  ListingsCollection,
                  Photo,
                  Region]
    end

    # A new class of admin, (Harley, Joseph, etc) who shouldnt have the ability to destroy records, but read everything
    if agent.read_only_admin?
      can :manage, :Listing
      can :manage, :Deposit
    end

    # A user, typically an office assistant, who can do some backend-y tasks.
    if agent.admin?
      can [:approve, :edit, :approved, :rejected, :reject, :verify], CheckRequest
      can [:read], CheckRequestType
      can [:streeteasy], Listing
      can [:manage_photos], Location
      can :manage, [Deposit, DepositTransaction, DepositClient]
      can :read, [Office]
    end

    # An agent who can grant acccess to other users
    if agent.employer?
      can [:employ,
           :hire,
           :fire,
           :probation,
           :place_on_probation,
           :remove_from_probation,
           :place_on_suspension,
           :remove_from_suspension], Agent
      can [:read, :claim], JobApplication
    end

    # A user who has back-end access to Nooklyn.
    if agent.employee?
      can [:pending,
           :rented,
           :my_rented,
           :manage_photos,
           :gallery,
           :table_view,
           :my_listings,
           :create,
           :update,
           :search,
           :change_status,
           :craigslist], Listing
      can [:create], GuideStory
      can [:create], LocationPhoto
      can [:create, :update], Location
      can [:create, :return, :read], KeyCheckout
      can [:read, :update], Lead
      can :read, [DepositTransaction, DepositClient]
      can [:read, :signed_and_approved, :refunded, :backed_out_deposits], Deposit
      can :manage, Photo
    end

    # An agent who has proven untrustworthy to follow up with leads
    if agent.on_probation?
      cannot :manage, Lead
    end

    # A user who is currently an employee but we want to remove access from typical employee actions
    if agent.suspended?
      cannot :manage, [Listing, Lead, Photo]
      cannot [:create, :update], [Location, GuideStory]
      cannot [:create, :return, :read], KeyCheckout
      can :create, Lead
    end

    # Logged in user
    if agent.id?
      can :create, ListingsCollection
      can [:create, :read, :approved, :rejected], CheckRequest
      can :manage, ListingsCollection, agent_id: agent.id
      can [:mates], Neighborhood
      can [:read, :create, :like, :unlike, :nudge], [MatePost, RoomPost]
      can [:update, :make_private, :make_public], [MatePost, RoomPost], agent_id: agent.id
      can :manage, Room, agent_id: agent.id
      can [:like, :unlike], Listing
      can [:like, :unlike], Location
      can [:rm_favorites, :rm_settings, :rm_leads, :my_collections], Agent
    end
  end
end
