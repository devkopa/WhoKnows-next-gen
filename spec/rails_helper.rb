# spec/rails_helper.rb

# --- MUST set RAILS_ENV before loading environment ---
ENV['RAILS_ENV'] ||= 'test'
abort("The Rails environment is running in production mode!") if ENV['RAILS_ENV'] == 'production'

# --- SIMPLECOV MUST BE CONFIGURED BEFORE ANY CODE IS LOADED ---
require 'simplecov'
require 'json'
require 'pathname'

SimpleCov.root(File.expand_path('..', __dir__))

# Use only HTML formatter - SimpleCov automatically generates .resultset.json
SimpleCov.formatter = SimpleCov::Formatter::HTMLFormatter

SimpleCov.start 'rails' do
  add_filter '/bin/'
  add_filter '/db/'
  add_filter '/spec/'
  add_filter '/test/'
  add_filter '/config/'

  # Post-process .resultset.json to convert absolute paths to relative paths for SonarQube
  at_exit do
    SimpleCov.result.format!

    resultset_path = File.join(SimpleCov.coverage_dir, '.resultset.json')
    if File.exist?(resultset_path)
      data = JSON.parse(File.read(resultset_path))
      root_path = SimpleCov.root

      # Convert absolute paths to relative paths in the coverage data
      data.each do |_command_name, command_data|
        next unless command_data['coverage']

        new_coverage = {}
        command_data['coverage'].each do |file_path, coverage_data|
          relative_path = Pathname.new(file_path)
                                  .relative_path_from(Pathname.new(root_path))
                                  .to_s
                                  .gsub('\\', '/')

          # SimpleCov uses different formats - normalize to just line array for SonarQube
          if coverage_data.is_a?(Hash) && coverage_data['lines']
            # If it's a hash with 'lines', extract just the lines array
            new_coverage[relative_path] = coverage_data['lines']
          else
            # Otherwise use as-is (should already be an array)
            new_coverage[relative_path] = coverage_data
          end
        end

        command_data['coverage'] = new_coverage
      end

      File.write(resultset_path, JSON.pretty_generate(data))
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
