require "net/http"
require "uri"
require "json"

module Services
class WikiCrawlerService
  API_ENDPOINT = "https://en.wikipedia.org/w/api.php"
  USER_AGENT = "WhoKnowsWikiCrawler/1.0 (https://example.com)"

  def self.scrape_for(query, limit: 1)
    return [] if query.to_s.strip.empty?

    search_params = {
      action: "query",
      list: "search",
      srsearch: query,
      srlimit: limit,
      format: "json"
    }

    search_json = get_json(API_ENDPOINT, search_params)

    log_debug("WikiCrawlerService search response for '#{query}': #{search_json.inspect}")

    if search_json && search_json["query"] && search_json["query"]["search"]
      titles = search_json["query"]["search"].map { |s| s["title"] }
    else
      opensearch_params = { action: "opensearch", search: query, limit: limit, namespace: 0, format: "json" }
      opensearch_json = get_json(API_ENDPOINT, opensearch_params)
      log_debug("WikiCrawlerService opensearch response for '#{query}': #{opensearch_json.inspect}")

      titles = Array(opensearch_json && opensearch_json[1])
    end

    titles = Array(titles).map(&:to_s).reject(&:empty?)
    return [] if titles.empty?

    extract_params = {
      action: "query",
      prop: "extracts",
      exintro: true,
      explaintext: true,
      titles: titles.join("|"),
      format: "json"
    }

    extracts_json = get_json(API_ENDPOINT, extract_params)
    pages = extracts_json.dig("query", "pages") || {}

    pages.map do |pageid, page|
      title = page["title"]
      url_title = title.gsub(" ", "_")
      url = "https://en.wikipedia.org/wiki/#{URI.encode_www_form_component(url_title)}"
      content = page["extract"] || ""
      { title: title, url: url, content: content }
    end
  rescue StandardError => e
    log_warn("WikiCrawlerService error for '#{query}': #{e.message}")
    []
  end

  def self.get_json(endpoint, params)
    uri = URI(endpoint)
    uri.query = URI.encode_www_form(params)

    http = Net::HTTP.new(uri.host, uri.port)
    http.use_ssl = (uri.scheme == "https")
    http.open_timeout = 5
    http.read_timeout = 10

    req = Net::HTTP::Get.new(uri.request_uri)
    req["User-Agent"] = USER_AGENT

    resp = http.request(req)
    return nil unless resp.is_a?(Net::HTTPSuccess)
    JSON.parse(resp.body)
  end

  private

  def self.log_debug(message)
    if defined?(Rails) && Rails.logger
      Rails.logger.debug(message)
    else
      puts message
    end
  end

  def self.log_warn(message)
    if defined?(Rails) && Rails.logger
      Rails.logger.warn(message)
    else
      warn message
    end
  end
end
end
