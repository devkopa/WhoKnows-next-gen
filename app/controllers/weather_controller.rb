class WeatherController < ApplicationController
  include HTTParty
  base_uri "https://api.openweathermap.org/data/2.5"

  def index
    city = params[:city] || "Copenhagen"
    api_key = ENV["OPENWEATHER_API_KEY"]

    if api_key.blank?
      @error = "API key not set"
      return
    end

    response = self.class.get("/weather", query: { q: city, appid: api_key, units: "metric" })

    if response.success?
      data = response.parsed_response
      @city = data["name"]
      @temperature = data["main"]["temp"]
      @condition = data["weather"][0]["description"]
      @coord = data["coord"]
    else
      @error = "Unable to fetch weather for #{city}"
    end
  end
end