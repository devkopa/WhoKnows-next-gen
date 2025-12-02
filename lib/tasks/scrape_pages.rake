namespace :scrape do
  # Ensure service is loaded when running rake tasks (Rails may not autoload lib/ during rake)
  require File.expand_path("../../services/wiki_crawler_service", __FILE__)
  desc "Scrape pages based on top searches"
  task top_searches: :environment do
    # Get top 5 search queries from logs
    top_queries = SearchLog.group(:query).order("count_id DESC").count("id").keys.first(5)

    # Map queries to URLs to scrape (replace with real sources)
    query_to_urls = {
      "ruby" => [ "https://www.ruby-lang.org/en/documentation/" ],
      "rails" => [ "https://guides.rubyonrails.org/" ],
      "javascript" => [ "https://developer.mozilla.org/en-US/docs/Web/JavaScript" ],
      "arsenal fc" => [ "https://en.wikipedia.org/wiki/Arsenal_F.C." ],
      "world cup" => [ "https://en.wikipedia.org/wiki/FIFA_World_Cup" ]
    }

    top_queries.each do |query|
      # Try Wikipedia first
      wiki_results = WikiCrawlerService.scrape_for(query, limit: 3)

      if wiki_results.any?
        wiki_results.each do |data|
          Page.find_or_create_by(url: data[:url]) do |page|
            page.title = data[:title]
            page.content = data[:content]
          end
          Rails.logger.info("Indexed wiki page: #{data[:url]}")
        end
        next
      end

      # Fallback to hardcoded mapping and ScraperService
      urls = query_to_urls[query.downcase]
      next unless urls

      ScraperService.scrape_multiple(urls).each do |data|
        Page.find_or_create_by(url: data[:url]) do |page|
          page.title = data[:title]
          page.content = data[:content]
        end
        Rails.logger.info("Indexed page: #{data[:url]}")
      end
    end
  end
end
