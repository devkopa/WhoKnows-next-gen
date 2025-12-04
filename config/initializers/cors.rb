# config/initializers/cors.rb
Rails.application.config.middleware.insert_before 0, Rack::Cors do
  allow do
    origins "http://20.251.217.144:3000", "http://localhost:3000"
    resource "*",
      headers: :any,
      methods: [ :get, :post, :patch, :put, :delete, :options ],
      credentials: true
  end
end
