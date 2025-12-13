require "rails_helper"

RSpec.describe Api::UsersController, type: :request do
  let(:password) { "SuperSecret1" }

  describe "POST /api/login" do
    let!(:user) { User.create!(username: "tester", email: "tester@example.com", password: password, password_confirmation: password, force_password_reset: false) }

    it "logs in successfully and redirects to root" do
      post "/api/login", params: { username: user.username, password: password }
      expect(session[:user_id]).to eq(user.id)
      expect(response).to have_http_status(:found)
      expect(response).to redirect_to(Rails.application.routes.url_helpers.root_path)
    end

    it "increments failure metric, sets flash and redirects to login on bad creds" do
      post "/api/login", params: { username: user.username, password: "wrong" }
      expect(session[:user_id]).to be_nil
      expect(flash[:alert]).to eq("Wrong username or password")
      expect(response).to redirect_to(Rails.application.routes.url_helpers.login_path)
    end

    it "redirects to change password when force_password_reset is true" do
      user.update!(force_password_reset: true)
      post "/api/login", params: { username: user.username, password: password }
      expect(response).to have_http_status(:found)
      expect(response).to redirect_to("/change_password")
    end

    it "rescues update_columns errors without failing login" do
      allow(User).to receive(:find_by).and_return(user)
      allow(user).to receive(:authenticate).and_return(true)
      allow(user).to receive(:update_columns).and_raise(StandardError.new("boom"))

      post "/api/login", params: { username: user.username, password: password }
      expect(session[:user_id]).to eq(user.id)
      expect(response).to have_http_status(:found)
    end
  end

  describe "POST /api/register" do
    it "registers successfully and redirects with flash notice" do
      post "/api/register", params: { username: "newuser", email: "new@example.com", password: password, password_confirmation: password }
      expect(response).to have_http_status(:found)
      expect(response).to redirect_to(Rails.application.routes.url_helpers.register_path)
      expect(flash[:notice]).to eq("Registration successful. You can now log in.")
    end

    it "fails registration and redirects with flash alert" do
      # Invalid email format to trigger validation errors
      post "/api/register", params: { username: "baduser", email: "not-an-email", password: password, password_confirmation: password }
      expect(response).to have_http_status(:found)
      expect(response).to redirect_to(Rails.application.routes.url_helpers.register_path)
      expect(flash[:alert]).to be_present
    end
  end

  describe "logout" do
    let!(:user) { User.create!(username: "logoutuser", email: "logout@example.com", password: password, password_confirmation: password) }

    before do
      post "/api/login", params: { username: user.username, password: password }
      expect(session[:user_id]).to eq(user.id)
    end

    it "clears session and redirects for HTML request" do
      get "/logout"
      expect(session[:user_id]).to be_nil
      expect(response).to redirect_to(Rails.application.routes.url_helpers.login_path)
    end

    it "clears session and returns JSON for API request" do
      post "/api/logout", as: :json
      expect(session[:user_id]).to be_nil
      expect(response).to have_http_status(:ok)
      body = JSON.parse(response.body)
      expect(body["message"]).to eq("Logged out successfully")
    end
  end
end
