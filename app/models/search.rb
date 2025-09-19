class Search
  def self.perform_search(query)
    return [] if query.blank?
    Item.where("name ILIKE ?", "%#{query}%")
  end
end
