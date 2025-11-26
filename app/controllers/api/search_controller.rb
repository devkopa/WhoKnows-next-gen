module Api
  class SearchController < ApplicationController
    BASE_PAGE_URL = "/pages/"

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
        terms = query.split
        conditions = terms.map { |term| "(title ILIKE :t OR content ILIKE :t)" }.join(" AND ")
        values = { t: "%#{terms.join('%')}%" }

        Page.where(conditions, values)
      else
        Page.all
      end

      @results = pages.map do |page|
        {
          title: page.title,
          url: "#{BASE_PAGE_URL}#{page.id}",
          content: page.content.truncate(150)
        }
      end

      respond_to do |format|
        format.html { render template: "search/index" }
        format.json { render json: @results }
      end
    end

    private

    def log_search(query)
      SearchLog.create(query: query, user_ip: request.remote_ip)
      Rails.logger.info("Search logged: #{query}")
    end
  end
end
