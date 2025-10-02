class SearchRepository
  def self.search_items(query)
    return [] if query.blank?

    Item.where("name LIKE ?", "%#{query}%")
  end
end
