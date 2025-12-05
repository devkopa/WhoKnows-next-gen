require 'rails_helper'

RSpec.describe "Weathers", type: :request do
  describe "GET /api/weather" do
    before do
      ENV["OPENWEATHER_API_KEY"] = "fake-key"
    end

    it "returnerer http success når API svarer korrekt" do
      allow(Api::WeatherController).to receive(:get).with(any_args).and_return(
        double(success?: true, parsed_response: {
          "name" => "Copenhagen",
          "main" => { "temp" => 20 },
          "weather" => [ { "description" => "clear sky" } ],
          "coord" => { "lat" => 55.6761, "lon" => 12.5683 }
        })
      )

      get "/api/weather", params: { city: "Copenhagen" }
      expect(response).to have_http_status(:success)
      expect(response.parsed_body["city"]).to eq("Copenhagen")
      expect(response.parsed_body["temperature"]).to eq(20)
      expect(response.parsed_body["condition"]).to eq("clear sky")
      expect(response.parsed_body["coordinates"]).to eq({ "lat" => 55.6761, "lon" => 12.5683 })
    end

    it "returnerer fejl når API svarer med fejl" do
      allow(Api::WeatherController).to receive(:get).with(any_args).and_return(
        double(success?: false, parsed_response: {})
      )

      get "/api/weather", params: { city: "Copenhagen" }
      expect(response).to have_http_status(:bad_request)
      expect(response.parsed_body["error"]).to include("Unable to fetch weather for Copenhagen")
    end

    it "logger en warning hvis WeatherSearch.create fejler" do
      allow(Api::WeatherController).to receive(:get).with(any_args).and_return(
        double(success?: true, parsed_response: {
          "name" => "Copenhagen",
          "main" => { "temp" => 20 },
          "weather" => [ { "description" => "clear sky" } ],
          "coord" => { "lat" => 55.6761, "lon" => 12.5683 }
        })
      )

      allow(WeatherSearch).to receive(:create).and_raise(StandardError.new("DB error"))
      expect(Rails.logger).to receive(:warn).with(/Could not log api weather search: DB error/)

      get "/api/weather", params: { city: "Copenhagen" }
    end

    it "bruger default city når ingen param gives" do
      allow(Api::WeatherController).to receive(:get).with(any_args).and_return(
        double(success?: true, parsed_response: {
          "name" => "Copenhagen",
          "main" => { "temp" => 20 },
          "weather" => [ { "description" => "clear sky" } ],
          "coord" => { "lat" => 55.6761, "lon" => 12.5683 }
        })
      )

      get "/api/weather"
      expect(response).to have_http_status(:success)
      expect(response.parsed_body["city"]).to eq("Copenhagen")
    end
  end
end
