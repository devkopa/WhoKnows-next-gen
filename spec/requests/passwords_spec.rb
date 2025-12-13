# spec/requests/passwords_spec.rb
require 'rails_helper'

RSpec.describe "Passwords", type: :request do
  let(:user) { User.create!(username: 'testuser', email: 'test@example.com', password: 'oldpassword123') }

  describe "GET /change_password" do
    context "when user is not logged in" do
      it "redirects to login page" do
        get change_password_path
        expect(response).to have_http_status(:found)
        expect(response).to redirect_to(login_path)
      end
    end

    # Logged-in flows are covered by system tests; keep request specs simple
  end

  # PATCH flows require authenticated session; move to system specs if needed
end
