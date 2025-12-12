# spec/rails_helper.rb

# --- MUST set RAILS_ENV before loading environment ---
ENV['RAILS_ENV'] ||= 'test'
abort("The Rails environment is running in production mode!") if ENV['RAILS_ENV'] == 'production'

# --- SIMPLECOV MUST BE CONFIGURED BEFORE ANY CODE IS LOADED ---
require 'simplecov'
require 'simplecov-json'
require 'pathname'

SimpleCov.root(File.expand_path('..', __dir__))

# Custom formatter to ensure forward slashes for SonarQube
class SonarQubeFormatter < SimpleCov::Formatter::JSONFormatter
  def format(result)
    # First, normalize all file paths to use forward slashes
    result.files.each do |file|
      original_filename = file.instance_variable_get(:@filename)
      relative_path = Pathname.new(original_filename)
                              .relative_path_from(Pathname.new(SimpleCov.root))
                              .to_s
                              .gsub('\\', '/')
      file.instance_variable_set(:@filename, relative_path)
    end
    
    # Then call the original JSON formatter
    super(result)
  end
end

SimpleCov.formatter = SimpleCov::Formatter::MultiFormatter.new([
  SimpleCov::Formatter::HTMLFormatter,
  SonarQubeFormatter
])

SimpleCov.start 'rails' do
  add_filter '/bin/'
  add_filter '/db/'
  add_filter '/spec/'
  add_filter '/test/'
  add_filter '/config/'
end

# --- REQUIRE STATEMENTS FOR COVERAGE / TOOLS ---
require 'selenium/webdriver'
require_relative '../config/environment'
require 'rspec/rails'
require 'spec_helper'

# Autoload support files
Rails.root.glob('spec/support/**/*.rb').sort_by(&:to_s).each { |f| require f }

abort("The Rails environment is running in production mode!") if Rails.env.production?

Capybara.register_driver :edge do |app|
  Capybara::Selenium::Driver.new(
    app,
    browser: :edge,
    capabilities: Selenium::WebDriver::Remote::Capabilities.edge
  )
end

begin
  ActiveRecord::Migration.maintain_test_schema!
rescue ActiveRecord::PendingMigrationError => e
  abort e.to_s.strip
end

RSpec.configure do |config|
  config.fixture_paths = [ Rails.root.join('spec/fixtures') ]
  config.use_transactional_fixtures = true
  config.infer_spec_type_from_file_location!

  config.before(:each, type: :system) do
    driven_by :edge, screen_size: [ 1400, 1400 ]
  end

  config.before(:each, type: :request) do
    host! "test.host"
  end

  config.filter_rails_from_backtrace!
end
