# spec/system/user_flow_spec.rb
require 'rails_helper'

RSpec.describe "UserFlows", type: :system do
  before { driven_by(:selenium_edge_headless) }

  xit "registers, logs in, and logs out a user via actual sessions pages" do
    # --- Registration ---
    visit "/register"
    fill_in "username", with: "e2euser"
    fill_in "email", with: "e2euser@example.com"
    fill_in "password", with: "password"
    fill_in "password_confirmation", with: "password"
    click_button "Register"

    expect(page).to have_content("Registration successful")

    # --- Login ---
    visit "/login"
    fill_in "username", with: "e2euser"
    fill_in "password", with: "password"
    click_button "Login"

    expect(page).to have_content("Logout")

    # --- Logout ---
    click_link "Logout"
    expect(page).to have_current_path(login_path)
    expect(page).to have_content("Login")
    expect(page).not_to have_content("Logout")
  end
end
