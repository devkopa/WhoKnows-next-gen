require "httparty"
require "nokogiri"

class ScraperService
  # Simple scrape for a single URL
  def self.scrape(url)
    response = HTTParty.get(url)
    return unless response.success?

    doc = Nokogiri::HTML(response.body)
    {
      url: url,
      title: doc.at("title")&.text&.squish.presence || "No title",
      content: doc.at("body")&.text&.squish.presence || "No content"
    }
  rescue => e
    Rails.logger.error("Scrape failed for #{url}: #{e.message}")
    nil
  end

  # Example: scrape multiple URLs
  def self.scrape_multiple(urls)
    urls.map { |url| scrape(url) }.compact
  end
end
