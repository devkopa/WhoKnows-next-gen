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
  SimpleCov::Formatter::HTMLFormatter
])

SimpleCov.start do
  add_filter '/bin/'
  add_filter '/db/'
  add_filter '/spec/'
  # Include test controllers in coverage (was filtered out)
  add_filter '/config/'

  # Convert SimpleCov output to SonarQube Generic Coverage XML format
  at_exit do
    result = SimpleCov.result
    result.format!

    # Generate SonarQube Generic Coverage XML
    coverage_xml_path = File.join(SimpleCov.coverage_dir, 'coverage.xml')
    root_path = SimpleCov.root

    File.open(coverage_xml_path, 'w') do |file|
      file.puts '<?xml version="1.0" encoding="UTF-8"?>'
      file.puts '<coverage version="1">'

      result.files.each do |source_file|
        relative_path = Pathname.new(source_file.filename)
                                .relative_path_from(Pathname.new(root_path))
                                .to_s
                                .gsub('\\', '/')

        file.puts "  <file path=\"#{relative_path}\">"

        source_file.lines.each_with_index do |line, index|
          line_number = index + 1
          # line.coverage is nil for non-code lines, or integer for execution count
          next if line.coverage.nil?

          hits = line.coverage
          file.puts "    <lineToCover lineNumber=\"#{line_number}\" covered=\"#{hits > 0}\"/>"
        end

        file.puts '  </file>'
      end

      file.puts '</coverage>'
    end

    puts "SonarQube Generic Coverage XML generated at #{coverage_xml_path}"
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
