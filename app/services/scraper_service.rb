require "faraday"
require "nokogiri"
require "uri"
require "ipaddr"

class ScraperService
  # Simple scrape for a single URL with basic SSRF protection
  def self.scrape(url)
    return nil unless allowed_url?(url)

    conn = Faraday.new do |f|
      f.response :raise_error
      f.adapter Faraday.default_adapter
    end

    response = conn.get(url)
    return unless response.status.between?(200, 299)

    doc = Nokogiri::HTML(response.body)
    {
      url: url,
      title: doc.at("title")&.text&.squish.presence || "No title",
      content: doc.at("body")&.text&.squish.presence || "No content"
    }
  rescue Faraday::Error => e
    Rails.logger.error("Scrape failed for #{url}: #{e.message}")
    nil
  end

  # Example: scrape multiple URLs
  def self.scrape_multiple(urls)
    urls.map { |url| scrape(url) }.compact
  end

  private

  def self.allowed_url?(url)
    uri = URI.parse(url)
    return false unless uri.is_a?(URI::HTTP) || uri.is_a?(URI::HTTPS)
    host = uri.host
    return false if host.nil?

    begin
      addr = IPAddr.getaddr(host)
    rescue => _e
      return true
    end

    return false if addr.private? || addr.loopback? || addr.link_local? || addr.multicast?

    true
  end
end
