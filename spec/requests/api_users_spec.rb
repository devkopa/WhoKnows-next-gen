require 'rails_helper'

RSpec.describe "Test Users API", type: :request do
  let(:user_params) do
    {
      username: "testuser_#{SecureRandom.hex(4)}",
      email: "test_#{SecureRandom.hex(4)}@example.com",
      password: "password",
      password_confirmation: "password"
    }
  end

  describe "POST /test/register" do
    it "creates a new user" do
      post "/test/register", params: user_params.to_json,
           headers: { "CONTENT_TYPE" => "application/json", "ACCEPT" => "application/json" }

      expect(response).to have_http_status(:created)
      json = JSON.parse(response.body)
      expect(json["username"]).to eq(user_params[:username])
      expect(json["message"]).to eq("Registration successful")
    end
  end

  describe "POST /test/login" do
    let!(:user) { User.create!(user_params) }

    it "logs in a user with correct credentials" do
      post "/test/login", params: { username: user.username, password: "password" }.to_json,
           headers: { "CONTENT_TYPE" => "application/json", "ACCEPT" => "application/json" }

      expect(response).to have_http_status(:success)
      json = JSON.parse(response.body)
      expect(json["username"]).to eq(user.username)
      expect(json["message"]).to eq("Login successful")
    end

    it "fails with wrong password" do
      post "/test/login", params: { username: user.username, password: "wrong" }.to_json,
           headers: { "CONTENT_TYPE" => "application/json", "ACCEPT" => "application/json" }

      expect(response).to have_http_status(:unauthorized)
      json = JSON.parse(response.body)
      expect(json["message"]).to eq("Invalid username or password")
    end
  end

  describe "GET /test/logout" do
    let!(:user) { User.create!(user_params) }

    before do
      post "/test/login", params: { username: user.username, password: "password" }.to_json,
           headers: { "CONTENT_TYPE" => "application/json", "ACCEPT" => "application/json" }
    end

    it "logs out the user via JSON" do
      get "/test/logout", headers: { "ACCEPT" => "application/json" }

      expect(response).to have_http_status(:ok)
      json = JSON.parse(response.body)
      expect(json["message"]).to eq("Logged out successfully")
    end
  end
end
