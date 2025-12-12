# spec/rails_helper.rb

# --- MUST set RAILS_ENV before loading environment ---
ENV['RAILS_ENV'] ||= 'test'
abort("The Rails environment is running in production mode!") if ENV['RAILS_ENV'] == 'production'

# --- SIMPLECOV MUST BE CONFIGURED BEFORE ANY CODE IS LOADED ---
require 'simplecov'
require 'simplecov-json'
require 'json'
require 'pathname'

SimpleCov.root(File.expand_path('..', __dir__))

SimpleCov.formatters = SimpleCov::Formatter::MultiFormatter.new([
  SimpleCov::Formatter::HTMLFormatter,
  SimpleCov::Formatter::JSONFormatter
])

SimpleCov.start 'rails' do
  add_filter '/bin/'
  add_filter '/db/'
  add_filter '/spec/'
  add_filter '/test/'
  add_filter '/config/'

  # Post-process coverage.json to use relative paths for SonarQube
  at_exit do
    SimpleCov.result.format!

    coverage_json_path = File.join(SimpleCov.coverage_dir, 'coverage.json')
    if File.exist?(coverage_json_path)
      data = JSON.parse(File.read(coverage_json_path))
      root_path = SimpleCov.root

      # Convert absolute paths to relative paths
      data['files'].each do |file_data|
        absolute_path = file_data['filename']
        relative_path = Pathname.new(absolute_path)
                                .relative_path_from(Pathname.new(root_path))
                                .to_s
                                .gsub('\\', '/')
        file_data['filename'] = relative_path
      end

      File.write(coverage_json_path, JSON.pretty_generate(data))
    end
  end
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
