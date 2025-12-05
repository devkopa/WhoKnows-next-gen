require 'rails_helper'

RSpec.describe "Test Users API", type: :request do
  JSON_HEADERS = {
    "CONTENT_TYPE" => "application/json",
    "ACCEPT" => "application/json"
  }.freeze

  TEST_LOGIN_PATH    = "/test/login".freeze
  TEST_REGISTER_PATH = "/test/register".freeze
  TEST_LOGOUT_PATH   = "/test/logout".freeze

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
      post TEST_REGISTER_PATH,
           params: { user: user_params }.to_json,
           headers: JSON_HEADERS

      expect(response).to have_http_status(:created)
      json = JSON.parse(response.body)
      expect(json["username"]).to eq(user_params[:username])
      expect(json["message"]).to eq("Registration successful")
    end

    it "logs registration attempt" do
      fake_logger = double("Logger")
      allow(fake_logger).to receive(:info)
      allow(Rails).to receive(:logger).and_return(fake_logger)

      post TEST_REGISTER_PATH,
           params: { user: user_params }.to_json,
           headers: JSON_HEADERS

      expect(fake_logger).to have_received(:info).with(a_string_including("TEST REGISTER called"))
    end

    it "fails when user cannot be saved" do
      invalid_params = user_params.merge(password_confirmation: "mismatch")
      post TEST_REGISTER_PATH,
           params: { user: invalid_params }.to_json,
           headers: JSON_HEADERS

      expect(response).to have_http_status(:unprocessable_entity)
      json = JSON.parse(response.body)
      expect(json["errors"]).to include("Password confirmation doesn't match Password")
    end

    it "falls back to params when JSON parsing fails" do
      post TEST_REGISTER_PATH,
           params: { user: user_params },
           headers: { "CONTENT_TYPE" => "application/x-www-form-urlencoded" }

      expect(response).to have_http_status(:created)
    end
  end

  describe "POST /test/login" do
    let!(:user) { User.create!(user_params) }

    it "logs in a user with correct credentials" do
      post TEST_LOGIN_PATH,
           params: { user: { username: user.username, password: "password" } }.to_json,
           headers: JSON_HEADERS

      expect(response).to have_http_status(:success)
      json = JSON.parse(response.body)
      expect(json["username"]).to eq(user.username)
      expect(json["message"]).to eq("Login successful")
    end

    it "fails with wrong password" do
      post TEST_LOGIN_PATH,
           params: { user: { username: user.username, password: "wrong" } }.to_json,
           headers: JSON_HEADERS

      expect(response).to have_http_status(:unauthorized)
      json = JSON.parse(response.body)
      expect(json["message"]).to eq("Invalid username or password")
    end

    it "increments USER_LOGINS and updates last_login on success" do
      stub_const("USER_LOGINS", double("Counter", increment: true))
      allow_any_instance_of(User).to receive(:update_columns)

      post TEST_LOGIN_PATH,
           params: { user: { username: user.username, password: "password" } }.to_json,
           headers: JSON_HEADERS

      expect(USER_LOGINS).to have_received(:increment).with(labels: { status: "success" })
    end
  end

  describe "GET /test/logout" do
    let!(:user) { User.create!(user_params) }

    before do
      post TEST_LOGIN_PATH,
           params: { user: { username: user.username, password: "password" } }.to_json,
           headers: JSON_HEADERS
    end

    it "logs out the user via JSON" do
      get TEST_LOGOUT_PATH, headers: JSON_HEADERS

      expect(response).to have_http_status(:ok)
      json = JSON.parse(response.body)
      expect(json["message"]).to eq("Logged out successfully")
    end
  end
end
