# spec/requests/sessions_spec.rb
require 'rails_helper'

RSpec.describe "Sessions", type: :request do
  describe "GET /login" do
    it "returns http success" do
      get login_path
      expect(response).to have_http_status(:success)
    end

    # Logged-in flow is covered by system tests; request specs keep simple
  end

  describe "GET /register" do
    it "returns http success" do
      get register_path
      expect(response).to have_http_status(:success)
    end

    # Logged-in flow is covered by system tests; request specs keep simple
  end
end
