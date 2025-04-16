Rails.application.routes.draw do
  devise_for :users, controllers: { omniauth_callbacks: 'users/omniauth_callbacks' }
  root "courses#search_page"

  resources :courses, only: [:index, :show] do
    collection do
      get :search_page
      get :search
    end
  end
  
  # Define universities routes with collection action first
  resources :universities, only: [:show] do
    collection do
      get :map_search
    end
  end

  # Currency routes
  post 'set_currency', to: 'currencies#set_currency', as: :set_currency

  # Reveal health status on /up that returns 200 if the app boots with no exceptions, otherwise 500.
  # Can be used by load balancers and uptime monitors to verify that the app is live.
  get "up" => "rails/health#show", as: :rails_health_check

  # Add exchange rates route
  get 'exchange_rates', to: 'currencies#exchange_rates'
end
