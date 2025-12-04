# --- REQUIRE STATEMENTS MUST BE FIRST ---

require 'simplecov'
require 'simplecov-json'
require 'selenium/webdriver'
require_relative '../config/environment'
require 'rspec/rails'
require 'spec_helper'

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

# --- REST OF THE FILE CAN FOLLOW ---

ENV['RAILS_ENV'] ||= 'test'
abort("The Rails environment is running in production mode!") if Rails.env.production?

# Autoload support files
Rails.root.glob('spec/support/**/*.rb').sort_by(&:to_s).each { |f| require f }

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

  config.before(:each, type: :system) do
    driven_by :edge, screen_size: [ 1400, 1400 ]
  end

  config.filter_rails_from_backtrace!
end
