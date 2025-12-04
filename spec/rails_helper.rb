# spec/rails_helper.rb

# --- MUST set RAILS_ENV before loading environment ---
ENV['RAILS_ENV'] ||= 'test'
abort("The Rails environment is running in production mode!") if ENV['RAILS_ENV'] == 'production'

# --- REQUIRE STATEMENTS FOR COVERAGE / TOOLS (must be before app code) ---
require 'simplecov'
require 'simplecov-json'
require 'selenium/webdriver'
require_relative '../config/environment'
require 'rspec/rails'
require 'spec_helper'

# Autoload support files
Rails.root.glob('spec/support/**/*.rb').sort_by(&:to_s).each { |f| require f }

# --- SIMPLECOV MUST BE CONFIGURED BEFORE ANY CODE IS LOADED ---
SimpleCov.formatter = SimpleCov::Formatter::MultiFormatter.new([
  SimpleCov::Formatter::HTMLFormatter,
  SimpleCov::Formatter::JSONFormatter
])

SimpleCov.start 'rails' do
  add_filter '/bin/'
  add_filter '/db/'
  add_filter '/spec/'
end

# Abort if somehow the environment is not test
abort("The Rails environment is running in production mode!") if Rails.env.production?

# Capybara custom driver
Capybara.register_driver :edge do |app|
  Capybara::Selenium::Driver.new(
    app,
    browser: :edge,
    capabilities: Selenium::WebDriver::Remote::Capabilities.edge
  )
end

# ActiveRecord schema checks
begin
  ActiveRecord::Migration.maintain_test_schema!
rescue ActiveRecord::PendingMigrationError => e
  abort e.to_s.strip
end

# RSpec config
RSpec.configure do |config|
  config.fixture_paths = [ Rails.root.join('spec/fixtures') ]
  config.use_transactional_fixtures = true
  config.infer_spec_type_from_file_location!

  # Ensure system specs use the Edge driver
  config.before(:each, type: :system) do
    driven_by :edge, screen_size: [ 1400, 1400 ]
  end

  # IMPORTANT: make request specs use a known host to avoid HostAuthorization blocking.
  # Rails/RSpec uses test.host by default; ensure request specs use it explicitly.
  config.before(:each, type: :request) do
    # host! is provided by Rails test helpers and sets the Host header for requests
    host! "test.host"
  end

  # If you prefer localhost instead, uncomment the next line:
  # config.before(:each, type: :request) { host! "localhost" }

  config.filter_rails_from_backtrace!
end
