Rails.application.routes.draw do
  # Define constants for reused paths
  LOGIN_PATH = "/login".freeze
  REGISTER_PATH = "/register".freeze

  # Swagger / OpenAPI
  mount Rswag::Ui::Engine => "/api-docs"
  mount Rswag::Api::Engine => "/api-docs"

  get "up" => "rails/health#show", as: :rails_health_check
  get "/metrics", to: "metrics#index"

  # Health checks for monitoring
  get "/health", to: "health#show"
  get "/health/ready", to: "health#ready"
  get "/health/live", to: "health#live"
  get "/health/metrics", to: "health#metrics_summary"

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

  # Password change feature removed

  namespace :api do
    get "/weather", to: "weather#show"
    post REGISTER_PATH, to: "users#register"
    post LOGIN_PATH, to: "users#login"
    post "/logout", to: "users#logout"
    get "/search", to: "search#index"
  end

  namespace :test do
      post REGISTER_PATH, to: "users#register"
      post LOGIN_PATH, to: "users#login"
      get  "/logout", to: "users#logout"
  end
end
