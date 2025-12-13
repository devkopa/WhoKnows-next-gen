require 'rails_helper'

RSpec.describe "Weather", type: :request do
  describe "GET /weather" do
    before do
      ENV["OPENWEATHER_API_KEY"] = "test-key-123"
    end

    context "successful weather response" do
      it "fetches weather data and displays it" do
        weather_response = {
          "name" => "Copenhagen",
          "main" => { "temp" => 15.5 },
          "weather" => [{ "description" => "cloudy" }],
          "coord" => { "lat" => 55.6761, "lon" => 12.5683 }
        }

        mock_response = double(success?: true, parsed_response: weather_response)
        allow(WeatherController).to receive(:get).and_return(mock_response)
        allow(WeatherSearch).to receive(:create)
        allow(WEATHER_REQUESTS).to receive(:increment)

        get "/weather", params: { city: "Copenhagen" }

        expect(response).to have_http_status(:success)
        expect(response.body).to include("Copenhagen")
        expect(response.body).to include("15.5")
        expect(response.body).to include("Cloudy")
      end

      it "uses default city when no params provided" do
        weather_response = {
          "name" => "Copenhagen",
          "main" => { "temp" => 10 },
          "weather" => [{ "description" => "sunny" }],
          "coord" => { "lat" => 55.6761, "lon" => 12.5683 }
        }

        mock_response = double(success?: true, parsed_response: weather_response)
        allow(WeatherController).to receive(:get).and_return(mock_response)
        allow(WEATHER_REQUESTS).to receive(:increment)

        expect(WeatherSearch).to receive(:create).with(hash_including(city: "Copenhagen"))

        get "/weather"

        expect(response).to have_http_status(:success)
      end

      it "calls WeatherSearch.create with city and user_ip" do
        weather_response = {
          "name" => "Paris",
          "main" => { "temp" => 12 },
          "weather" => [{ "description" => "rainy" }],
          "coord" => { "lat" => 48.8566, "lon" => 2.3522 }
        }

        mock_response = double(success?: true, parsed_response: weather_response)
        allow(WeatherController).to receive(:get).and_return(mock_response)
        allow(WEATHER_REQUESTS).to receive(:increment)

        expect(WeatherSearch).to receive(:create).with(hash_including(
          city: "Paris",
          user_ip: "127.0.0.1"
        ))

        get "/weather", params: { city: "Paris" }

        expect(response).to have_http_status(:success)
      end

      it "increments WEATHER_REQUESTS counter" do
        weather_response = {
          "name" => "London",
          "main" => { "temp" => 8 },
          "weather" => [{ "description" => "foggy" }],
          "coord" => { "lat" => 51.5074, "lon" => -0.1278 }
        }

        mock_response = double(success?: true, parsed_response: weather_response)
        allow(WeatherController).to receive(:get).and_return(mock_response)
        allow(WeatherSearch).to receive(:create)
        expect(WEATHER_REQUESTS).to receive(:increment)

        get "/weather", params: { city: "London" }

        expect(response).to have_http_status(:success)
      end
    end

    context "when WeatherSearch.create fails" do
      it "logs a warning and continues" do
        weather_response = {
          "name" => "Berlin",
          "main" => { "temp" => 5 },
          "weather" => [{ "description" => "snowy" }],
          "coord" => { "lat" => 52.5200, "lon" => 13.4050 }
        }

        mock_response = double(success?: true, parsed_response: weather_response)
        allow(WeatherController).to receive(:get).and_return(mock_response)
        allow(WEATHER_REQUESTS).to receive(:increment)

        allow(WeatherSearch).to receive(:create).and_raise(StandardError, "DB Error")
        expect(Rails.logger).to receive(:warn).with(/Could not log weather search: DB Error/)

        get "/weather", params: { city: "Berlin" }

        expect(response).to have_http_status(:success)
      end
    end

    context "when WEATHER_REQUESTS.increment fails" do
      it "logs a warning and continues" do
        weather_response = {
          "name" => "Amsterdam",
          "main" => { "temp" => 6 },
          "weather" => [{ "description" => "windy" }],
          "coord" => { "lat" => 52.3676, "lon" => 4.9041 }
        }

        mock_response = double(success?: true, parsed_response: weather_response)
        allow(WeatherController).to receive(:get).and_return(mock_response)
        allow(WeatherSearch).to receive(:create)
        allow(WEATHER_REQUESTS).to receive(:increment).and_raise(StandardError, "Prometheus Error")
        expect(Rails.logger).to receive(:warn).with(/Could not increment WEATHER_REQUESTS: Prometheus Error/)

        get "/weather", params: { city: "Amsterdam" }

        expect(response).to have_http_status(:success)
      end
    end

    context "API error response" do
      it "handles API error and displays error message" do
        mock_response = double(success?: false, parsed_response: {})
        allow(WeatherController).to receive(:get).and_return(mock_response)
        allow(WeatherSearch).to receive(:create)
        allow(WEATHER_REQUESTS).to receive(:increment)

        get "/weather", params: { city: "UnknownCity" }

        expect(response).to have_http_status(:success)
        expect(response.body).to include("Unable to fetch weather for UnknownCity")
      end
    end

    context "environment variable" do
      it "fetches OPENWEATHER_API_KEY from environment" do
        weather_response = {
          "name" => "Stockholm",
          "main" => { "temp" => 2 },
          "weather" => [{ "description" => "icy" }],
          "coord" => { "lat" => 59.3293, "lon" => 18.0686 }
        }

        mock_response = double(success?: true, parsed_response: weather_response)
        allow(WeatherController).to receive(:get).and_return(mock_response)
        allow(WeatherSearch).to receive(:create)
        allow(WEATHER_REQUESTS).to receive(:increment)

        get "/weather", params: { city: "Stockholm" }

        expect(response).to have_http_status(:success)
      end
    end
  end
end
