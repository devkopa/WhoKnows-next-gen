class PagesRepository
  class << self
    def find_by_search(search_string, language)
      scope = Page.all
      unless language.nil? || language.to_s.strip.empty?
        scope = scope.where("language LIKE ?", "%#{sanitize_sql_like(language)}%")
      end
      unless search_string.nil? || search_string.to_s.strip.empty?
        s = sanitize_sql_like(search_string)
        # search in content OR title OR url (case-insensitive)
        scope = scope.where(
          "(content LIKE ? OR LOWER(title) LIKE LOWER(?) OR LOWER(url) LIKE LOWER(?))",
          "%#{s}%", "%#{s}%", "%#{s}%"
        )

        # Also try a normalized form without dots/extra punctuation to match titles like 'Arsenal F.C.'
        norm = sanitize_sql_like(normalize_search(search_string))
        scope = scope.or(
          Page.where("LOWER(REPLACE(title, '.', '')) LIKE LOWER(?) OR LOWER(REPLACE(url, '.', '')) LIKE LOWER(?)", "%#{norm}%", "%#{norm}%")
        )
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

    def normalize_search(str)
      # remove punctuation like dots, commas and collapse spaces
      str.to_s.gsub(/[\.,\/#!$%\^&\*;:{}=\-_`~()]/, ' ').squeeze(' ').strip
    end
  end
end
