class WeatherController < ApplicationController
  API_BASE = "https://api.openweathermap.org/data/2.5"

  class << self
    def get(path, query = {})
      url = path.start_with?("http") ? path : "#{API_BASE}#{path}"
      resp = Faraday.get(url, query)
      obj = Object.new
      obj.define_singleton_method(:success?) { resp.status.between?(200, 299) }
      obj.define_singleton_method(:parsed_response) { JSON.parse(resp.body) }
      obj.define_singleton_method(:status) { resp.status }
      obj.define_singleton_method(:body) { resp.body }
      obj
    end
  end

  def index
    city = params[:city] || "Copenhagen"
    api_key = ENV.fetch("OPENWEATHER_API_KEY")

    # log the weather page search in dedicated table
    begin
      WeatherSearch.create(city: city, user_ip: request.remote_ip)
    rescue => e
      Rails.logger.warn("Could not log weather search: #{e.message}")
    end

    begin
      response = self.class.get("/weather", q: city, appid: api_key, units: "metric")
    rescue => e
      Rails.logger.error("Weather API request failed: #{e.message}")
      response = nil
    end

    begin
      WEATHER_REQUESTS.increment
    rescue => e
      Rails.logger.warn("Could not increment WEATHER_REQUESTS: #{e.message}")
    end

    if response && response_success?(response)
      data = response_parsed(response)
      @city = data["name"]
      @temperature = data["main"]["temp"]
      @condition = data["weather"][0]["description"]
      @coord = data["coord"]
    else
      @error = "Unable to fetch weather for #{city}"
    end
  end

  private

  def response_success?(resp)
    return resp.status.between?(200, 299) if resp.respond_to?(:status)
    return resp.success? if resp.respond_to?(:success?)
    false
  end

  def response_parsed(resp)
    return resp.parsed_response if resp.respond_to?(:parsed_response)
    return JSON.parse(resp.body) if resp.respond_to?(:body)
    {}
  end
end
