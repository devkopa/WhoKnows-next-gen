Rails.application.routes.draw do
  # Define constants for reused paths
  LOGIN_PATH = "/login".freeze
  REGISTER_PATH = "/register".freeze

  # Swagger / OpenAPI
  mount Rswag::Ui::Engine => "/api-docs"
  mount Rswag::Api::Engine => "/api-docs"

  get "up" => "rails/health#show", as: :rails_health_check
  get "/metrics", to: "metrics#index"
  root "home#index"

  get "/sla", to: "pages#sla"

  # Authentication
  get LOGIN_PATH, to: "sessions#login"
  get REGISTER_PATH, to: "sessions#register"
  get "/logout", to: "api/users#logout", as: :logout

  # RESTful Users for Rswag
  resources :users, only: [ :index, :show, :create ]

  # Weather
  get "/weather", to: "weather#index"

  # Security breach change password
  get "/change_password", to: "passwords#edit", as: :change_password
  patch "/change_password", to: "passwords#update", as: :update_password

  namespace :api do
    get "/weather", to: "weather#show"
    post REGISTER_PATH, to: "users#register"
    post LOGIN_PATH, to: "users#login"
    get "/search", to: "search#index"
  end

  namespace :test do
      post REGISTER_PATH, to: "users#register"
      post LOGIN_PATH, to: "users#login"
      get  "/logout", to: "users#logout"
  end
end
