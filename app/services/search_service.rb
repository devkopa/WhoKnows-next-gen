class SearchService
  MAX_RESULTS = 100

  def self.perform_search(query)
    q = query.to_s.strip
    return [] if q.empty?

    normalized = q.downcase.strip
    Item.where('LOWER(name) LIKE ?', "%#{normalized}%").limit(MAX_RESULTS)
  end
end
