# spec/models/weather_search_spec.rb
require 'rails_helper'

RSpec.describe WeatherSearch, type: :model do
  describe "creation" do
    it "creates a weather search record" do
      weather_search = WeatherSearch.create!(city: 'Copenhagen')

      expect(weather_search).to be_persisted
      expect(weather_search.city).to eq('Copenhagen')
    end
  end
end
