class Api::WeatherController < ApplicationController
  include HTTParty
  base_uri "https://api.openweathermap.org/data/2.5"

  def show
    city = params[:city] || "Copenhagen"
    api_key = ENV["OPENWEATHER_API_KEY"]

    if api_key.blank?
      render json: { error: "API key not set" }, status: :unprocessable_entity
      return
    end

    response = self.class.get("/weather", query: { q: city, appid: api_key, units: "metric" })

      # log API weather request
      begin
        WeatherSearch.create(city: city, user_ip: request.remote_ip)
    rescue => e
      Rails.logger.warn("Could not log api weather search: #{e.message}")
    end

    if response.success?
      data = response.parsed_response
      render json: {
        city: data["name"],
        temperature: data["main"]["temp"],
        condition: data["weather"][0]["description"],
        coordinates: data["coord"]
      }
    else
      render json: { error: "Unable to fetch weather for #{city}" }, status: :bad_request
    end
  end
end
