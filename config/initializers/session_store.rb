# config/initializers/session_store.rb
Rails.application.config.session_store :cookie_store,
  key: "_openapi_session",
  same_site: :lax,   # :lax allows fetch with credentials
  secure: Rails.env.production?  # secure in prod
