class SearchLog < ApplicationRecord
  validates :query, presence: true
end
