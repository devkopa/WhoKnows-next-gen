Rails.application.routes.draw do
  get "weather/index"
  # Swagger / OpenAPI
  mount Rswag::Ui::Engine => "/api-docs"
  mount Rswag::Api::Engine => "/api-docs"

  get "up" => "rails/health#show", as: :rails_health_check
  root "home#index"

  # Authentication
  get "/login", to: "sessions#login"
  post "api/login", to: "users#login"
  get "/register", to: "sessions#register"
  post "api/register", to: "users#register"
  get "/logout", to: "users#logout"

  # RESTful Users for Rswag
  resources :users, only: [ :index, :show, :create ]

  # Search
  get "api/search", to: "search#index"

  # Weather
  get "/weather", to: "weather#index"
end
