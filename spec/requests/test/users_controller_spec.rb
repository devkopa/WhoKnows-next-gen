# frozen_string_literal: true

require "rails_helper"

RSpec.describe "Test::UsersController", type: :request do
  let(:headers) { { "CONTENT_TYPE" => "application/json" } }
  let(:valid_attributes) do
    {
      user: {
        username: "tester",
        email: "tester@example.com",
        password: "password123",
        password_confirmation: "password123"
      }
    }
  end

  describe "POST /test/register" do
    it "creates a user and returns created" do
      expect do
        post "/test/register", params: valid_attributes.to_json, headers: headers
      end.to change(User, :count).by(1)

      expect(response).to have_http_status(:created)
      body = JSON.parse(response.body)
      expect(body["message"]).to eq("Registration successful")
      expect(body["username"]).to eq("tester")
      expect(body["id"]).to be_present
    end

    it "returns errors for invalid payload" do
      invalid_payload = valid_attributes.deep_dup
      invalid_payload[:user][:username] = ""

      expect do
        post "/test/register", params: invalid_payload.to_json, headers: headers
      end.not_to change(User, :count)

      expect(response).to have_http_status(:unprocessable_entity)
      body = JSON.parse(response.body)
      expect(body["errors"]).to include("Username can't be blank")
    end
  end

  describe "POST /test/login" do
    let!(:user) do
      User.create!(
        username: "tester",
        email: "tester@example.com",
        password: "password123",
        password_confirmation: "password123"
      )
    end

    it "logs in with valid credentials and updates session" do
      post "/test/login", params: { user: { username: user.username, password: "password123" } }, as: :json

      expect(response).to have_http_status(:ok)
      expect(session[:user_id]).to eq(user.id)
      expect(JSON.parse(response.body)["message"]).to eq("Login successful")
    end

    it "returns unauthorized with invalid credentials and uses params fallback" do
      post "/test/login", params: { username: user.username, password: "wrong" }

      expect(response).to have_http_status(:unauthorized)
      expect(session[:user_id]).to be_nil
      expect(JSON.parse(response.body)["message"]).to eq("Invalid username or password")
    end

    it "handles last_login update failures gracefully" do
      allow_any_instance_of(User).to receive(:update_columns).and_raise(StandardError, "boom")

      post "/test/login", params: { user: { username: user.username, password: "password123" } }, as: :json

      expect(response).to have_http_status(:ok)
      expect(JSON.parse(response.body)["message"]).to eq("Login successful")
    end
  end

  describe "GET /test/logout" do
    it "clears the session and returns ok" do
      user = User.create!(
        username: "logout-user",
        email: "logout@example.com",
        password: "password123",
        password_confirmation: "password123"
      )

      post "/test/login", params: { user: { username: user.username, password: "password123" } }, as: :json
      expect(session[:user_id]).to eq(user.id)

      get "/test/logout"

      expect(response).to have_http_status(:ok)
      expect(session[:user_id]).to be_nil
      expect(JSON.parse(response.body)["message"]).to eq("Logged out successfully")
    end
  end
end
