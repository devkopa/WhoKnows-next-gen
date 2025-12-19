# Load Capybara support for RSpec
require "capybara/rspec"
require "selenium-webdriver"

# Register Microsoft Edge drivers
Capybara.register_driver :selenium_edge do |app|
  # Visible Edge browser
  options = Selenium::WebDriver::Options.edge
  # Tilføj evt. yderligere argumenter her
  Capybara::Selenium::Driver.new(app, browser: :edge, options: options)
end

Capybara.register_driver :selenium_edge_headless do |app|
  # Headless Edge browser (no window opens)
  options = Selenium::WebDriver::Options.edge
  options.add_argument("--headless=new")
  options.add_argument("--disable-gpu")
  options.add_argument("--window-size=1400,1400")

  Capybara::Selenium::Driver.new(app, browser: :edge, options: options)
end

# Capybara global configuration
Capybara.configure do |config|
  # Use Microsoft Edge instead of Chrome
  # use :selenium_edge for visible browser
  # use :selenium_edge_headless for headless tests
  config.default_driver = :selenium_edge_headless

  # App and server settings
  # Allow overriding in CI or local runs via env vars; otherwise let Capybara pick a free port.
  if ENV['CAPYBARA_APP_HOST']
    config.app_host = ENV['CAPYBARA_APP_HOST']
  end

  if ENV['CAPYBARA_SERVER_PORT']
    config.server_port = Integer(ENV['CAPYBARA_SERVER_PORT']) rescue nil
  end

  # Optional: Capybara wait time for async requests
  config.default_max_wait_time = 5
end
