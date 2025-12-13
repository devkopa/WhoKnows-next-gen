class SearchService
  def self.perform_search(query)
    return [] if query.blank?

    # Sanitize and normalize query
    normalized_query = query.strip.downcase

    # Use optimized query with ILIKE for case-insensitive search
    # Consider adding database indexes on name column for performance
    Item.where("LOWER(name) LIKE ?", "%#{normalized_query}%")
        .limit(100) # Limit results for performance
  end
end
