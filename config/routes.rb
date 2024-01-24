Rails.application.routes.draw do
  # devise_for :users, path: '', path_names: {
  #   sign_up: 'sign_up', login: 'sign_in'
  # }
  devise_for :users,
             controllers: {
               registrations: 'users/registrations',
               sessions: 'users/sessions'
             }
  devise_scope :user do
    get '/users/sign_out' => 'devise/session#destroy'
  end

  authenticated :user do
    get 'dashboard', to: 'dashboard#index', as: :dashboard
    get '', to: 'dashboard#index'
  end

  resources :countries do
    resources :cities do
      resources :places
    end
  end

  resources :countries
  resources :cities
  resources :places

  # root to: "countries#index"
  root to: 'landing_page#index'

  # Define your application routes per the DSL in https://guides.rubyonrails.org/routing.html
  # Reveal health status on /up that returns 200 if the app boots with no exceptions, otherwise 500.
  # Can be used by load balancers and uptime monitors to verify that the app is live.
  get 'up' => 'rails/health#show', as: :rails_health_check

  match '*unmatched', to: 'application#not_found_method', via: :all

  # Defines the root path route ("/")
  # root "posts#index"
end
