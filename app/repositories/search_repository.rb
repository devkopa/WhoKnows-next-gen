module SearchRepository
  def self.search_items(query)
    q = query.to_s.strip
    return [] if q.empty?

    Item.where("name LIKE ?", "%#{q.downcase}%")
  end
end
