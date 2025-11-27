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

    # fallback lookup (DuckDuckGo HTML); throttles per host
    lookup = Scraper::SearchLookup.new(throttle_seconds: 1)
    audit_rows = []

    top_queries.each do |query|
      urls = query_to_urls[query.downcase]
      if urls.nil? || urls.empty?
        puts "No mapping for query: #{query.inspect} - performing lookup"
        urls = lookup.lookup(query, limit: 5)
        puts "Lookup found URLs: #{urls.inspect}"
        audit_rows << [query, urls.join('|'), 'lookup']
      else
        audit_rows << [query, urls.join('|'), 'mapping']
      end

      next if urls.nil? || urls.empty?

      puts "Query: #{query.inspect} -> URLs: #{urls.inspect}"
      ScraperService.scrape_multiple(urls).each do |data|
        Page.find_or_create_by(url: data[:url]) do |page|
          page.title = data[:title]
          page.content = data[:content]
        end
        Rails.logger.info("Indexed page: #{data[:url]}")
      end
    end

    # write audit CSV
    require 'csv'
    CSV.open('tmp/top_search_results.csv','w') do |csv|
      csv << ['query','urls','source']
      audit_rows.each { |r| csv << r }
    end
    puts "Wrote tmp/top_search_results.csv"
  end
end
