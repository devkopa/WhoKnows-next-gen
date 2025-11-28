class PagesService
  class << self
    def find_by_search(search_string, language)
      results = PagesRepository.find_by_search(search_string, language)
      results.is_a?(Array) ? results : []
    rescue StandardError => e
      Rails.logger.error("Service layer search error: #{e.message}")
      []
    end
  end
end
