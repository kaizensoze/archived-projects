Rails.application.routes.draw do

  resources :check_request_types
  resources :check_requests do
    member do
      get "approve"
      get "reject"
      get "verify"
    end
    resources :check_request_documents
  end
  get 'checks' => 'check_requests#index'
  get 'checks/verified' => 'check_requests#verified'
  get 'checks/approved' => 'check_requests#approved'
  get 'checks/rejected' => 'check_requests#rejected'

  resources :job_applications do
    member do
      get "claim"
    end
  end

  root to: 'pages#home'

  # Listings
  resources :listings do
    member do
      get 'like'
      get 'unlike'
      get 'gallery'
      get 'manage_photos'
      get 'craigslist'
    end
  end

  resources :listings_collections do
    member do
      post "add_listing"
      post "remove_listing"
      get "make_private"
      get "make_public"
    end
  end

  get "rentals" => "listings#rentals"
  get "commercial" => "listings#commercial"
  get "sales" => "listings#sales"

  get "listings-partial" => "listings#_listings"
  get "hoods-partial/:id" => "neighborhoods#_listings"

  # Neighborhoods
  resources :neighborhoods do
    resources :listings
    member do
      get 'mates'
      get 'rooms'
      get 'locations'
    end
  end
  get "hoods/all" => "neighborhoods#all"

  # Standard CRUDs
  resources :location_categories,
            :rooms,
            :room_categories,
            :feedbacks,
            :location_photos,
            :regions,
            :offices,
            :guide_story_photos,
            :guides


  resources :guide_stories do
    member do
      get 'manage_photos'
    end
  end

  resources :photos do
    member do
      get "mark_as_featured"
      get "mark_as_not_featured"
    end
  end

  resources :locations do
    member do
      get 'like'
      get 'unlike'
      get 'manage_photos'
    end
  end

  # Rooms & Mates
  resources :roommates
  resources :room_posts do
    resources :rooms
    member do
      get 'like'
      get 'unlike'
      get 'make_private'
      get 'make_public'
    end
  end

  resources :mate_posts do
    member do
      get 'like'
      get 'unlike'
      get 'make_private'
      get 'make_public'
    end
    collection do
      post 'nudge'
    end
  end

  get "mates" => "mate_posts#index"
  get "mates/all" => "mate_posts#all"

  get "rm_favorites" => "agents#rm_favorites"
  get "rm_settings" => "agents#rm_settings"
  get "my_collections" => "agents#my_collections"

  # Messaging Related
  resources :conversations do
    member do
      post :mark_as_archived
      post :mark_as_unarchived
    end

    get :archive, on: :collection
  end
  resources :conversation_messages, only: [:create]

  # User routes (user model is named agent)
  devise_for :agents, :controllers => { :omniauth_callbacks => "agents/omniauth_callbacks" }
  get 'agents/:id/mates' => 'agents#mates', as: 'agent_favorite_mates'
  devise_scope :agent do
    get 'register', to: 'devise/registrations#new', as: :register
    get 'edit_agent_settings', to: 'devise/registrations#edit_agent_settings'
    get 'change_password', to: 'devise/registrations#change_password'
    get 'login', to: 'devise/sessions#new', as: :login
  end
  resources :agents do
    member do
      get 'roommate_leads'
    end
  end

  post "facebook-login" => "facebook_auth#facebook_login"

  # API Routes
  jsonapi_resources :agents
  jsonapi_resources :regions
  jsonapi_resources :neighborhoods
  jsonapi_resources :listings
  jsonapi_resources :favorites   # favorite listings
  jsonapi_resources :hearts
  jsonapi_resources :ignored_listings
  jsonapi_resources :listing_ignores
  jsonapi_resources :mates
  jsonapi_resources :mate_favorites
  jsonapi_resources :mate_post_likes
  jsonapi_resources :mate_ignores
  jsonapi_resources :mate_post_ignores
  jsonapi_resources :rooms
  jsonapi_resources :locations
  jsonapi_resources :location_categories
  jsonapi_resources :location_favorites
  jsonapi_resources :location_likes
  jsonapi_resources :conversations
  jsonapi_resources :conversation_participants
  jsonapi_resources :conversation_messages
  jsonapi_resources :listings_collections

  namespace :api do
    namespace :v1 do
      resources :sessions, only: [:create]
      jsonapi_resources :agents, only: [:index, :show, :create, :update]
      jsonapi_resources :regions, only: [:index, :show]
      jsonapi_resources :neighborhoods, only: [:index, :show]
      jsonapi_resources :listings, only: [:index, :show]
      jsonapi_resources :favorites, only: [:index, :show]
      jsonapi_resources :hearts
      jsonapi_resources :ignored_listings, only: [:index, :show]
      jsonapi_resources :listing_ignores
      jsonapi_resources :mates, only: [:index, :show, :create, :update]
      jsonapi_resources :mate_favorites, only: [:index, :show]
      jsonapi_resources :mate_post_likes
      jsonapi_resources :mate_ignores, only: [:index, :show]
      jsonapi_resources :mate_post_ignores
      jsonapi_resources :rooms, only: [:index, :show]  # temporary until used, in which create/update will be added
      jsonapi_resources :locations, only: [:index, :show]
      jsonapi_resources :location_categories, only: [:index, :show]
      jsonapi_resources :location_favorites, only: [:index, :show]
      jsonapi_resources :location_likes
      jsonapi_resources :conversations
      jsonapi_resources :conversation_participants, only: [:create, :update]
      jsonapi_resources :conversation_messages, only: [:create]
      jsonapi_resources :listings_collections, only: [:index, :show]
    end
  end

  namespace :admin do
    resources :neighborhoods
    resources :agents do
      collection do
        get 'employees'
      end
    end
    get 'agents_search', to: 'agents#search'
    resources :listings
    get 'listings_search', to: 'listings#search'
    get 'available_listings', to: 'listings#available'
    get 'listings_need_updates', to: 'listings#listings_need_updates'
    get 'pending_listings', to: 'listings#pending'
    get 'rented_listings', to: 'listings#rented'
    get 'modern_layout_locations', to: 'locations#modern_layout_locations'
    resources :locations do
      member do
        get 'make_feature'
        get 'remove_feature'
      end
    end
    resources :room_posts do
      member do
        get 'make_private'
        get 'make_public'
      end
    end
    resources :mate_posts do
      member do
        get 'make_feature'
        get 'make_private'
        get 'make_public'
      end
    end
    get "settings/dashboard"
  end

  # Employee/Admin Routes
  namespace :matrix do
    get "index" => 'listings#index'
    get "commercial" => 'listings#commercial'
    get "/pending" => 'listings#pending'
    get "/sales" => 'listings#sales'
    get "rented" => 'listings#rented'
    get "rented/me" => 'listings#my_rented'
    get 'table_view' => 'listings#table_view'
    get 'listings/syndication' => 'listings#syndication'
    get 'my_listings' => 'listings#my_listings'
    get 'listings/search', to: 'listings#search'
    get 'hoods/:id' => 'neighborhoods#show', as: 'neighborhood'
    get 'hoods/:id/rented' => 'neighborhoods#rented', as: 'neighborhood_rented'
    get "guide" => "pages#agent_guide"
    get "recruiting/guide" => "pages#recruiting_guide"
    get "guide/roommates_match_ups" => "pages#roommate_match_up"
    get "statistics" => "pages#statistics"
    get "statistics/daily_active_mate_profiles" => "statistics#daily_active_mate_profiles"
    get "documents" => "pages#documents"
    get "videos" => "pages#videos"
    get "videos/how_to_show" => "pages#how_to_show"
    get "videos/how_to_post_beginner" => "pages#how_to_post_beginner"
    get "videos/how_to_post_intermediate" => "pages#how_to_post_intermediate"
    get "videos/approval" => "pages#approval"
    get "videos/phone_call" => "pages#phone_call"
    get "videos/deposit" => "pages#the_deposit"
    get "videos/craigslist_broker_ads" => "pages#craigslist_broker_ads"

    resources :listings, only: [] do
      post 'change_status', on: :member
    end

    resources :key_checkouts do
      member do
        get 'return'
      end
    end

    resources :offices, :regions
    get 'transactions' => "deposit_transactions#index"
    resources :deposits do
      shallow do
        resources :deposit_attachments
        resources :deposit_transactions
        resources :deposit_clients
      end
      member do
        get "mark_as_refund"
      end
    end
    resources :deposit_statuses
    get "refunded_deposits" => "deposits#refunded"
    get "backed_out_deposits" => "deposits#backed_out_deposits"
    get "signed_and_approved_deposits" => "deposits#signed_and_approved"

    resources :agents do
      member do
        get 'employ'
        get 'fire'
        get 'place_on_probation'
        get 'remove_from_probation'
        get 'place_on_suspension'
        get 'remove_from_suspension'
      end
      collection do
        get 'hire'
        get 'probation'
        get 'stats'
      end
    end
  end

  get '/keys', to: redirect('/matrix/key_checkouts')
  get '/matrix', to: redirect('/matrix/index')
  get '/stats', to: redirect('/matrix/statistics')
  get '/admin', to: redirect('/admin/settings/dashboard')

  # Leads
  resources :leads do
    resources :lead_updates
  end

  # Pages
  get "about" => "pages#about"
  get "culture" => "pages#culture"
  get "privacy" => "pages#privacy"
  get "contact" => "leads#new"
  get "fair-housing" => "pages#fair_housing"
  get "renterguide" => "pages#renterguide"
  get "support" => "feedbacks#new"
  get "jobs" => "pages#jobs"
  get "home" => "pages#home"
  get "styleguide" => "pages#styleguide"
  get "terms" => "pages#terms"
  get "legal" => "pages#legal"
  get "documents" => "pages#documents"

  get "buildings/17monitor" => "pages#monitor"
  get "buildings/common_pacific" => "pages#common_pacific"
end
