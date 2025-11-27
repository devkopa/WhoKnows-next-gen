class WeatherSearch < ApplicationRecord
  validates :city, presence: true
end
