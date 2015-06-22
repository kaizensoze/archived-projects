Rails.application.routes.draw do
  apipie

  devise_for :admin_users, ActiveAdmin::Devise.config
  ActiveAdmin.routes(self)

  devise_for :users, controllers: { confirmations: 'confirmations' }
  devise_scope :user do
    get '/users/confirmation/confirmed' => 'devise/confirmations#confirmed'
  end
  
  root :to => redirect('/cms')

  namespace :cms do
    root :to => redirect('cms/dashboard')

    get 'dashboard' => 'dashboard#index'

    resources :background_images do
      collection do
        post :sort
      end

      member do
        post :set_active_inactive
      end
    end

    resources :menus

    resources :gym_schedules

    resources :poll do
      collection do
        post :save
      end
    end

    resources :announcements do
      collection do
        post :sort
      end

      member do
        post :set_active_inactive
      end
    end

    resources :help_now_items do
      collection do
        post :sort
      end
    end

    resources :who_to_call_subjects do
      collection do
        post :sort
      end

      resources :who_to_call_items do
        collection do
          post :sort
        end
      end
    end

    resources :did_you_know_subjects do
      collection do
        post :sort
      end

      resources :did_you_know_items do
        collection do
          post :sort
        end
      end
    end
  end

  namespace :api, defaults: {format: 'json'} do
    namespace :v1 do
      # resources :background_images
      # resources :menus
      # resources :gym_schedules
      # resources :announcements
      post '/send-verification-request', to: 'home#send_verification_request'
      post '/check-verified', to: 'home#check_verified'
      get '/today', to: 'home#today'
      post '/poll-submit', to: 'home#poll_submit'
      get '/poll-results', to: 'home#poll_results'
      get '/help-now', to: 'home#help_now'
      get '/who-to-call', to: 'home#who_to_call'
      get '/did-you-know', to: 'home#did_you_know'
    end
  end
end
