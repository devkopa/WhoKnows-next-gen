# frozen_string_literal: true

require "rails_helper"

RSpec.describe "Test::UsersController", type: :request do
  let(:headers) { { "CONTENT_TYPE" => "application/json" } }
  let(:valid_payload) do
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
    it "creates a user with JSON body and returns created" do
      expect do
        post "/test/register", params: valid_payload.to_json, headers: headers
      end.to change(User, :count).by(1)

      expect(response).to have_http_status(:created)
      body = JSON.parse(response.body)
      expect(body["message"]).to eq("Registration successful")
      expect(body["username"]).to eq("tester")
      expect(body["id"]).to be_present
    end

    it "creates a user with params fallback and returns created" do
      expect do
        post "/test/register", params: valid_payload
      end.to change(User, :count).by(1)

      expect(response).to have_http_status(:created)
      body = JSON.parse(response.body)
      expect(body["message"]).to eq("Registration successful")
    end

    it "returns errors when validation fails" do
      invalid_payload = valid_payload.deep_dup
      invalid_payload[:user][:username] = ""

      expect do
        post "/test/register", params: invalid_payload.to_json, headers: headers
      end.not_to change(User, :count)

      expect(response).to have_http_status(:unprocessable_entity)
      body = JSON.parse(response.body)
      expect(body["errors"]).to include("Username can't be blank")
    end

    it "returns errors when email is invalid" do
      invalid_payload = valid_payload.deep_dup
      invalid_payload[:user][:email] = "not-an-email"

      expect do
        post "/test/register", params: invalid_payload.to_json, headers: headers
      end.not_to change(User, :count)

      expect(response).to have_http_status(:unprocessable_entity)
      body = JSON.parse(response.body)
      expect(body["errors"]).not_to be_empty
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

    it "logs in with valid credentials via JSON body" do
      payload = { user: { username: "tester", password: "password123" } }
      post "/test/login", params: payload.to_json, headers: headers

      expect(response).to have_http_status(:ok)
      expect(session[:user_id]).to eq(user.id)
      body = JSON.parse(response.body)
      expect(body["message"]).to eq("Login successful")
      expect(body["id"]).to eq(user.id)
      expect(body["username"]).to eq("tester")
    end

    it "logs in with valid credentials via params fallback" do
      post "/test/login", params: { user: { username: "tester", password: "password123" } }

      expect(response).to have_http_status(:ok)
      expect(session[:user_id]).to eq(user.id)
      body = JSON.parse(response.body)
      expect(body["message"]).to eq("Login successful")
    end

    it "returns unauthorized with wrong password" do
      post "/test/login", params: { user: { username: "tester", password: "wrongpassword" } }

      expect(response).to have_http_status(:unauthorized)
      expect(session[:user_id]).to be_nil
      body = JSON.parse(response.body)
      expect(body["message"]).to eq("Invalid username or password")
    end

    it "returns unauthorized with non-existent user" do
      post "/test/login", params: { user: { username: "nonexistent", password: "password123" } }

      expect(response).to have_http_status(:unauthorized)
      expect(session[:user_id]).to be_nil
      body = JSON.parse(response.body)
      expect(body["message"]).to eq("Invalid username or password")
    end

    it "increments USER_LOGINS metric on successful login" do
      metric_mock = double(increment: true)
      stub_const("USER_LOGINS", metric_mock)

      post "/test/login", params: { user: { username: "tester", password: "password123" } }

      expect(response).to have_http_status(:ok)
      expect(metric_mock).to have_received(:increment).with(labels: { status: "success" })
    end

    it "increments USER_LOGINS metric on failed login" do
      metric_mock = double(increment: true)
      stub_const("USER_LOGINS", metric_mock)

      post "/test/login", params: { user: { username: "tester", password: "wrong" } }

      expect(response).to have_http_status(:unauthorized)
      expect(metric_mock).to have_received(:increment).with(labels: { status: "failure" })
    end

    it "handles last_login update failures gracefully" do
      allow_any_instance_of(User).to receive(:update_columns).and_raise(StandardError, "boom")

      post "/test/login", params: { user: { username: "tester", password: "password123" } }

      expect(response).to have_http_status(:ok)
      body = JSON.parse(response.body)
      expect(body["message"]).to eq("Login successful")
    end
  end

  describe "GET /test/logout" do
    let!(:user) do
      User.create!(
        username: "logout-user",
        email: "logout@example.com",
        password: "password123",
        password_confirmation: "password123"
      )
    end

    it "logs out and clears the session" do
      post "/test/login", params: { user: { username: "logout-user", password: "password123" } }
      expect(session[:user_id]).to eq(user.id)

      get "/test/logout"

      expect(response).to have_http_status(:ok)
      expect(session[:user_id]).to be_nil
      body = JSON.parse(response.body)
      expect(body["message"]).to eq("Logged out successfully")
    end

    it "logs out without active session" do
      get "/test/logout"

      expect(response).to have_http_status(:ok)
      expect(session[:user_id]).to be_nil
      body = JSON.parse(response.body)
      expect(body["message"]).to eq("Logged out successfully")
    end
  end
end
