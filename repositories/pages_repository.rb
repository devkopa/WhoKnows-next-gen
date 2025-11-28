class PagesRepository
  class << self
    def find_by_search(search_string, language)
      scope = Page.all
      unless language.nil? || language.to_s.strip.empty?
        scope = scope.where("language LIKE ?", "%#{sanitize_sql_like(language)}%")
      end
      unless search_string.nil? || search_string.to_s.strip.empty?
        scope = scope.where("content LIKE ?", "%#{sanitize_sql_like(search_string)}%")
      end

      scope.to_a
    rescue StandardError => e
      Rails.logger.error("PagesRepository.find_by_search error: #{e.message}")
      []
    end

    private

    def sanitize_sql_like(string)
      ActiveRecord::Base.sanitize_sql_like(string.to_s)
    end
  end
end
