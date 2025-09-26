Rails.application.routes.draw do
  # Health check
  get "up" => "rails/health#show", as: :rails_health_check

  # Root
  root "home#index"

  # Authentication
  get "/login", to: "sessions#login"
  post "api/login", to: "users#login"
  get "/register", to: "sessions#register"
  post "api/register", to: "users#register"
  get  "/logout", to: "users#logout"

  # Search
  get "api/search", to: "search#index"
end
