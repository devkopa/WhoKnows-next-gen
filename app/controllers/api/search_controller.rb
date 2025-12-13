module Api
  class SearchController < ApplicationController
    BASE_PAGE_URL = "/pages/"
    MAX_RESULTS = 100

    def index
      query = params[:q].to_s.strip
      if query.present?
        log_search(query)
        begin
          SEARCH_REQUESTS.increment
        rescue => e
          Rails.logger.warn("Could not increment SEARCH_REQUESTS: #{e.message}")
        end
      end

      pages = if query.present?
        # Optimize search query with limit and select only needed fields
        terms = query.split
        conditions = terms.map { |term| "(title ILIKE :t OR content ILIKE :t)" }.join(" AND ")
        values = { t: "%#{terms.join('%')}%" }

        Page.where(conditions, values)
            .select(:id, :title, :url, :content)
            .limit(MAX_RESULTS)
      else
        Page.select(:id, :title, :url, :content)
            .limit(MAX_RESULTS)
      end

      @results = pages.map do |page|
        {
          title: page.title,
          url: (page.respond_to?(:url) && page.url.present?) ? page.url : "#{BASE_PAGE_URL}#{page.id}",
          content: page.content&.truncate(150) || ""
        }
      end

      respond_to do |format|
        format.html { render template: "search/index" }
        format.json { render json: { data: @results, count: @results.size } }
      end
    end

    private

    def log_search(query)
      # Async logging to avoid blocking request
      SearchLog.create(query: query, user_ip: request.remote_ip)
      Rails.logger.info("Search logged: #{query}")
    rescue => e
      Rails.logger.error("Failed to log search: #{e.message}")
    end
  end
end
