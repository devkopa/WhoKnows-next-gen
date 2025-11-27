class WeatherController < ApplicationController
  include HTTParty
  base_uri "https://api.openweathermap.org/data/2.5"

  def index
    city = params[:city] || "Copenhagen"
    api_key = ENV["OPENWEATHER_API_KEY"]

    # log the weather page search in dedicated table
    begin
      WeatherSearch.create(city: city, user_ip: request.remote_ip)
    rescue => e
      Rails.logger.warn("Could not log weather search: #{e.message}")
    end

    if api_key.blank?
      @error = "API key not set"
      return
    end

    response = self.class.get("/weather", query: { q: city, appid: api_key, units: "metric" })
    begin
      WEATHER_REQUESTS.increment
    rescue => e
      Rails.logger.warn("Could not increment WEATHER_REQUESTS: #{e.message}")
    end

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
