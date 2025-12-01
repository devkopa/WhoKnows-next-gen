# Create simulated users directly in the DB using Rails models.
# Run with:
# bundle exec rails runner scripts/create_simulated_users_db.rb NUM_USERS=100 START=2025-11-23 END=2025-11-27

require 'securerandom'
require 'date'
require 'httparty'

NUM_USERS = (ENV['NUM_USERS'] || 100).to_i
start_date = ENV['START'] ? Date.parse(ENV['START']) : Date.parse('2025-11-19')
end_date = ENV['END'] ? Date.parse(ENV['END']) : Date.parse('2025-11-27')
APP_URL = ENV.fetch('APP_URL', 'https://devkopa.dk')
# Paths can be overridden via env
REGISTER_PATH = ENV.fetch('REGISTER_PATH', '/api/register')
LOGIN_PATH    = ENV.fetch('LOGIN_PATH', '/api/login')
SEARCH_PATH   = ENV.fetch('SEARCH_PATH', '/api/search')
WEATHER_PATH  = ENV.fetch('WEATHER_PATH', '/api/weather')
SIMULATE = ENV['SIMULATE'] == 'true'

# Max acceptable response times (seconds). If exceeded, simulate user leaving.
MAX_RESPONSE_TIMES = {
  '/' => 10.0,
  '/search' => 10.0,
  '/weather' => 10.0,
  '/register' => 10.0,
  '/login' => 10.0,
  '/api/search' => 6.0,
  '/api/weather' => 6.0,
  '/api/register' => 10.0,
  '/api/login' => 10.0,
  '/api/logout' => 6.0
}

# Prefer English locale for names; fall back to a small English first-name list
use_custom_english_names = false
if defined?(Faker)
  begin
    if defined?(I18n) && I18n.respond_to?(:available_locales)
      locales = I18n.available_locales.map(&:to_s)
      if locales.include?('en') || locales.include?('en-US')
        Faker::Config.locale = 'en'
      else
        use_custom_english_names = true
      end
    else
      use_custom_english_names = true
    end
  rescue StandardError
    use_custom_english_names = true
  end
else
  use_custom_english_names = true
end

if use_custom_english_names
  FIRST = %w[James John Robert Michael William David Richard Joseph Thomas Charles Christopher Daniel Matthew Anthony Mark Donald Steven Paul]
end

puts "Creating #{NUM_USERS} users directly in DB (created_at between #{start_date} and #{end_date})"
created = 0
attempts = 0

# Preload some real page titles to make realistic search queries when possible
page_titles = []
begin
  page_titles = Page.limit(200).pluck(:title).map(&:to_s).reject(&:empty?)
rescue => _e
  # if Page model/table not available, keep empty
  page_titles = []
end

NUM_USERS.times do |i|
  attempts += 1
  # generate name
  if use_custom_english_names
    first = FIRST.sample
    last = LAST.sample
  else
    first = Faker::Name.first_name
    last = Faker::Name.last_name
  end

  # Username: use English first name (lowercase). Append short hex if collision.
  if use_custom_english_names
    base = FIRST.sample.downcase
  else
    base = Faker::Name.first_name.downcase.gsub(/[^a-z]/, '')
  end
  username = base.dup
  suffix_try = 0
  while User.exists?(username: username) && suffix_try < 10
    username = "#{base}#{SecureRandom.hex(2)}"
    suffix_try += 1
  end
  username = "#{base}_#{SecureRandom.hex(3)}" if User.exists?(username: username)
  email = "#{username}@example.com"
  password = SecureRandom.hex(6)

  # retry on validation errors up to a few times (e.g., uniqueness collisions)
  created_ok = false
  5.times do |try|
    begin
      user = User.create!(username: username, email: email, password: password, password_confirmation: password)
      # pick random time
      day_offset = rand((end_date - start_date).to_i + 1)
      date = start_date + day_offset
      time = Time.new(date.year, date.month, date.day, rand(0..23), rand(0..59), rand(0..59), "+00:00")
      user.update_columns(created_at: time, updated_at: time)
      print "."
      created += 1
      created_ok = true
      break
    rescue ActiveRecord::RecordInvalid => e
      # maybe username/email collision or other validation; tweak username/email and retry
      username = "#{base}_#{SecureRandom.hex(3)}"
      email = "#{username}@example.com"
    rescue StandardError => e
      warn "\nError creating user (#{e.class}): #{e.message}"
      break
    end
  end

  unless created_ok
    warn "\nFailed to create user after retries for base #{base}"
  end

  # small backoff
  sleep(0.005)
  
  # Optional: simulate login + actions for this created user
  if created_ok && SIMULATE
    begin
      # Login using username only (your request) and log response
      login_resp = nil
      begin
        resp = HTTParty.post("#{APP_URL}#{LOGIN_PATH}",
          body: { username: username, password: password }.to_json,
          headers: { 'Content-Type' => 'application/json' },
          follow_redirects: false)
      rescue => e
        warn "\nLogin request error for #{username}: #{e.message}"
      else
        puts "\nLogin attempt for #{username}: HTTP #{resp.code}"
        login_resp = resp if resp.code == 200 || resp.code == 302 || resp.code == 201
      end

      cookie = nil
      if login_resp
        cookie = (login_resp.headers['set-cookie'].is_a?(Array) ? login_resp.headers['set-cookie'].first : login_resp.headers['set-cookie'])
      end

      headers = cookie ? { 'Cookie' => cookie, 'Accept' => 'application/json' } : { 'Accept' => 'application/json' }

      # Perform at most one search and one weather call per user (with one retry if a call fails)
      searched = false
      weather_checked = false
      steps = rand(2..6)
      steps.times do
        # if both actions done, stop early
        break if searched && weather_checked

        action = [:search, :weather, :idle].sample
        case action
        when :search
          next if searched
          # build realistic query
          q = if page_titles.any? && rand < 0.6
                title = page_titles.sample
                words = title.split
                if words.size <= 3
                  title
                else
                  start_idx = rand(0..(words.size - 2))
                  words[start_idx, 2].join(' ')
                end
              else
                ["arsenal fc", "weather tomorrow", "coffee shops near me", "how to tie a tie",
                  "bitcoin price", "ruby on rails tutorial", "local cinema times",
                  "python list comprehension", "nearest petrol station", "who won the world cup",
                  "latest movies", "restaurant reviews", "current stock prices", "music charts",
                  "how to cook pasta", "best smartphones 2025", "local gyms", "train times",
                  "news headlines", "upcoming concerts", "movie showtimes near me", "football scores",
                  "easy cake recipes", "best laptops 2025", "yoga classes near me", "top podcasts",
                  "how to lose weight fast", "local weather forecast", "electric cars 2025",
                  "gardening tips", "new restaurants in town", "python for beginners", "how to meditate",
                  "fitness challenges", "travel destinations 2025", "top restaurants", "music festivals",
                  "how to knit", "world news today", "best hiking trails", "coffee brewing tips",
                  "local events this weekend", "basketball scores", "how to learn guitar", "crypto news",
                  "how to make pizza", "local library hours", "top Netflix shows", "best beaches in Europe",
                  "dog training tips", "movie reviews 2025", "DIY home projects", "best sci-fi books",
                  "how to code in JavaScript", "famous quotes", "car maintenance tips", "cheap flights Europe"
                ].sample
              end

          resp = HTTParty.get("#{APP_URL}#{SEARCH_PATH}", query: { q: q }, headers: headers)
          code = resp.respond_to?(:code) ? resp.code.to_i : 0
          puts "Search call for #{username}: HTTP #{code} (q=#{q})"
          if code < 200 || code >= 300
            # one retry
            sleep(0.05)
            resp = HTTParty.get("#{APP_URL}#{SEARCH_PATH}", query: { q: q }, headers: headers)
            code = resp.respond_to?(:code) ? resp.code.to_i : 0
            puts "Search retry for #{username}: HTTP #{code} (q=#{q})"
          end
          searched = true

        when :weather
          next if weather_checked
          city = %w[London Copenhagen New_York Tokyo Paris Berlin Sydney].sample
          city_param = city.gsub('_', ' ')
          resp = HTTParty.get("#{APP_URL}#{WEATHER_PATH}", query: { city: city_param }, headers: headers)
          code = resp.respond_to?(:code) ? resp.code.to_i : 0
          puts "Weather call for #{username}: HTTP #{code} (city=#{city_param})"
          if code < 200 || code >= 300
            sleep(0.05)
            resp = HTTParty.get("#{APP_URL}#{WEATHER_PATH}", query: { city: city_param }, headers: headers)
            code = resp.respond_to?(:code) ? resp.code.to_i : 0
            puts "Weather retry for #{username}: HTTP #{code} (city=#{city_param})"
          end
          weather_checked = true

        when :idle
          sleep(0.05 + rand * 0.2)
        end

        sleep(0.02)
      end

    rescue => e
      warn "\nSimulation for #{username} failed: #{e.class} #{e.message}"
    end
  end
end

puts "\nDone — created #{created} users (attempted #{NUM_USERS})."
