Rails.application.routes.draw do
  # Swagger / OpenAPI
  mount Rswag::Ui::Engine => "/api-docs"
  mount Rswag::Api::Engine => "/api-docs"

  get "up" => "rails/health#show", as: :rails_health_check
  root "home#index"

  # Authentication
  get "/login", to: "sessions#login"
  get "/register", to: "sessions#register"
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
    post "/register", to: "users#register"
    post "/login", to: "users#login"
    get "/search", to: "search#index"
  end

  namespace :test do
      post "/register", to: "users#register"
      post "/login", to: "users#login"
      get  "/logout", to: "users#logout"
  end
end
