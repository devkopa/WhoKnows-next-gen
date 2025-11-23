# spec/requests/weather_spec.rb
require 'rails_helper'

RSpec.describe "Weathers", type: :request do
  describe "GET /index" do
    it "returns http success" do
      # mock API call
      allow(HTTParty).to receive(:get).and_return(
        double(success?: true, parsed_response: {
          "name" => "Copenhagen",
          "main" => { "temp" => 20 },
          "weather" => [{ "description" => "clear sky" }],
          "coord" => { "lat" => 55.6761, "lon" => 12.5683 }
        })
      )

      get "/weather"
      expect(response).to have_http_status(:success)
    end
  end
end
