namespace :scrape do
  desc "Scrape pages based on top searches"
  task top_searches: :environment do
    # Get top 5 search queries from logs
    top_queries = SearchLog.group(:query).order("count_id DESC").count("id").keys.first(5)
    puts "Top queries: #{top_queries.inspect}"

    # Map queries to URLs to scrape (replace with real sources)
    query_to_urls = {
      "ruby" => [ "https://www.ruby-lang.org/en/documentation/" ],
      "rails" => [ "https://guides.rubyonrails.org/" ],
      "javascript" => [ "https://developer.mozilla.org/en-US/docs/Web/JavaScript" ]
      # Add more mappings as needed
    }

    top_queries.each do |query|
      urls = query_to_urls[query.downcase]
      next unless urls

      puts "Query: #{query.inspect} -> URLs: #{urls.inspect}"
      ScraperService.scrape_multiple(urls).each do |data|
        Page.find_or_create_by(url: data[:url]) do |page|
          page.title = data[:title]
          page.content = data[:content]
        end
        Rails.logger.info("Indexed page: #{data[:url]}")
      end
    end

    puts "Done"
  end
end
