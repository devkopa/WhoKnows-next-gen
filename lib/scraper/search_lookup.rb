require "open-uri"
require "nokogiri"
require "net/http"
require "uri"

module Scraper
  class SearchLookup
    USER_AGENT = "Mozilla/5.0 (compatible; WhoKnowsBot/1.0; +https://example.org/bot)".freeze

    def initialize(throttle_seconds: 1)
      @robots_cache = {}
      @throttle_seconds = throttle_seconds
      @last_request_at = {} # host => Time
    end

    # Return array of urls (strings) for a query (max limit)
    def lookup(query, limit: 5)
      urls = []
      # try multiple DuckDuckGo HTML endpoints and be resilient with retries
      endpoints = [
        "https://html.duckduckgo.com/html?q=",
        "https://duckduckgo.com/html?q="
      ]

      endpoints.each do |base|
        break if urls.uniq.size >= limit
        url = base + URI.encode_www_form_component(query)
        attempts = 0
        begin
          attempts += 1
          html = open_with_agent(url)
          doc = Nokogiri::HTML(html)

          # Try several selectors to catch variations
          anchors = doc.css('a.result__a, a[data-testid="result-title-a"], a.result__snippet, a')

          anchors.each do |a|
            href = a['href'] || a['data-href'] || a['data-url']
            next unless href

            # handle DuckDuckGo redirect links with uddg parameter
            if href.include?('uddg=')
              if href =~ /uddg=([^&]+)/
                decoded = CGI.unescape($1)
                begin
                  u = URI.parse(decoded)
                rescue URI::InvalidURIError
                  next
                end
              else
                next
              end
            else
              begin
                u = URI.parse(href)
              rescue URI::InvalidURIError
                next
              end
            end

            # accept absolute http/https links
            next unless u && u.scheme && u.scheme =~ /^https?$/i
            # skip internal ddg hosts
            next if u.host&.include?('duckduckgo')
            # robots check
            next unless allowed_by_robots?(u)

            urls << u.to_s
            break if urls.uniq.size >= limit
          end
        rescue => e
          Rails.logger.warn("SearchLookup.lookup attempt #{attempts} for #{url.inspect} failed: #{e.class} #{e.message}") if defined?(Rails)
          sleep(0.5 * attempts) if attempts < 3
          retry if attempts < 3
        end
      end
      urls.uniq
    end

    private

    def open_with_agent(url)
      uri = URI.parse(url)
      throttle_for!(uri.host)
      URI.open(uri.to_s, "User-Agent" => USER_AGENT, read_timeout: 10).read
    end

    def throttle_for!(host)
      last = @last_request_at[host]
      if last
        elapsed = Time.now - last
        if elapsed < @throttle_seconds
          sleep(@throttle_seconds - elapsed)
        end
      end
      @last_request_at[host] = Time.now
    end

    def allowed_by_robots?(uri)
      host = uri.host
      return false unless host
      robots = @robots_cache[host]
      unless robots
        robots = fetch_robots(host)
        @robots_cache[host] = robots
      end
      path = uri.path.empty? ? "/" : uri.path
      # crude check: if any Disallow entry matches prefix of path
      disallows = robots[:disallow] || []
      disallows.each do |d|
        return false if path.start_with?(d)
      end
      true
    end

    def fetch_robots(host)
      robots_url = "https://#{host}/robots.txt"
      data = { disallow: [] }
      begin
        throttle_for!(host)
        txt = URI.open(robots_url, "User-Agent" => USER_AGENT, read_timeout: 5).read
        current_agent = nil
        txt.each_line do |line|
          line = line.strip
          next if line.empty? || line.start_with?("#")
          if line =~ /^User-agent:\s*(.*)/i
            current_agent = $1.strip
          elsif line =~ /^Disallow:\s*(.*)/i
            dis = $1.strip
            # only honor User-agent: * or blank
            if current_agent == "*" || current_agent.nil? || current_agent == ""
              data[:disallow] << dis unless dis.empty?
            end
          end
        end
      rescue => _e
        # if fetching robots fails, default to allow
        data[:disallow] = []
      end
      data
    end
  end
end
