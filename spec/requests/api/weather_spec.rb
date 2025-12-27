require 'rails_helper'

RSpec.describe "Weathers", type: :request do
  describe "GET /api/weather" do
    let(:weather_response_data) do
      {
        "name" => "Copenhagen",
        "main" => { "temp" => 20 },
        "weather" => [ { "description" => "clear sky" } ],
        "coord" => { "lat" => 55.6761, "lon" => 12.5683 }
      }
    end

    before do
      ENV["OPENWEATHER_API_KEY"] = "fake-key"
    end

    context "med succes svar" do
      before do
        body = weather_response_data.to_json
        allow(Faraday).to receive(:get).and_return(double(status: 200, body: body))
        allow(WeatherSearch).to receive(:create)
      end

      it "returnerer http success når API svarer korrekt" do
        get "/api/weather", params: { city: "Copenhagen" }

        expect(response).to have_http_status(:success)
        expect(response.parsed_body["city"]).to eq("Copenhagen")
        expect(response.parsed_body["temperature"]).to eq(20)
        expect(response.parsed_body["condition"]).to eq("clear sky")
        expect(response.parsed_body["coordinates"]).to eq({ "lat" => 55.6761, "lon" => 12.5683 })
      end

      it "bruger default city når ingen param gives" do
        get "/api/weather"
        expect(response).to have_http_status(:success)
        expect(response.parsed_body["city"]).to eq("Copenhagen")
      end

      it "opretter WeatherSearch med city og user_ip" do
        expect(WeatherSearch).to receive(:create).with(hash_including(city: "Copenhagen", user_ip: "127.0.0.1"))
        get "/api/weather", params: { city: "Copenhagen" }
        expect(response).to have_http_status(:success)
      end

      it "henter ENV variabel OPENWEATHER_API_KEY" do
        get "/api/weather", params: { city: "Stockholm" }
        expect(response).to have_http_status(:success)
      end
    end

    context "API fejl" do
      before do
        allow(Faraday).to receive(:get).and_return(double(status: 500, body: ''.to_json))
        allow(WeatherSearch).to receive(:create)
      end

      it "returnerer fejl når API svarer med fejl" do
        get "/api/weather", params: { city: "Copenhagen" }

        expect(response).to have_http_status(:bad_request)
        expect(response.parsed_body["error"]).to include("Unable to fetch weather for Copenhagen")
      end
    end

      context "when Faraday raises an exception" do
        before do
          allow(Faraday).to receive(:get).and_raise(StandardError.new('boom'))
          allow(WeatherSearch).to receive(:create)
        end

        it "logs the error and returns bad_request" do
          expect(Rails.logger).to receive(:error).with(/Weather API request failed: boom/)
          get "/api/weather", params: { city: "Copenhagen" }

          expect(response).to have_http_status(:bad_request)
        end
      end

      context "when API returns an object without status or success?" do
        before do
          allow(Api::WeatherController).to receive(:get).and_return(Object.new)
          allow(WeatherSearch).to receive(:create)
        end

        it "treats response as failure (response_success? false)" do
          get "/api/weather", params: { city: "Copenhagen" }
          expect(response).to have_http_status(:bad_request)
        end
      end

      context "when Api.get returns object with status and body but no parsed_response" do
        before do
          json = { "name" => "Copenhagen", "main" => { "temp" => 5 }, "weather" => [ { "description" => "cold" } ], "coord" => { "lat" => 1 } }.to_json
          allow(Api::WeatherController).to receive(:get).and_return(double(status: 200, body: json))
          allow(WeatherSearch).to receive(:create)
        end

        it "parses body via JSON.parse and returns success" do
          get "/api/weather", params: { city: "Copenhagen" }
          expect(response).to have_http_status(:success)
          expect(response.parsed_body["city"]).to eq("Copenhagen")
        end
      end

      context "when Api.get responds with success? only and no body" do
        before do
          # Make the response treated as a failure so controller does not attempt to read missing fields
          allow(Api::WeatherController).to receive(:get).and_return(double(success?: false, parsed_response: {}))
          allow(WeatherSearch).to receive(:create)
        end

        it "returns bad_request because controller cannot parse missing fields" do
          get "/api/weather", params: { city: "Copenhagen" }
          expect(response).to have_http_status(:bad_request)
          expect(response.parsed_body["error"]).to include("Unable to fetch weather for Copenhagen")
        end
      end

    context "WeatherSearch fejl" do
      before do
        allow(Faraday).to receive(:get).and_return(double(status: 200, body: weather_response_data.to_json))
        allow(WeatherSearch).to receive(:create).and_raise(StandardError.new("DB error"))
      end

      it "logger en warning hvis WeatherSearch.create fejler" do
        expect(Rails.logger).to receive(:warn).with(/Could not log api weather search: DB error/)
        get "/api/weather", params: { city: "Copenhagen" }
        expect(response).to have_http_status(:success)
      end
    end
  end
end
