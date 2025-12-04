module Test
  class UsersController < ApplicationController
    skip_before_action :verify_authenticity_token, only: [ :login, :register, :logout ]

    # POST /test/register
    def register
      Rails.logger.info("TEST REGISTER called with params: #{params.inspect}")
      data = parse_request_data["user"] || parse_request_data

      user = User.new(
        username: data["username"],
        email: data["email"],
        password: data["password"],
        password_confirmation: data["password_confirmation"]
      )

      if user.save
        Rails.logger.info("User created successfully: id=#{user.id} username=#{user.username}")
        render json: { id: user.id, username: user.username, message: "Registration successful" }, status: :created
      else
        Rails.logger.warn("User creation failed: #{user.errors.full_messages.join(', ')}")
        render json: { errors: user.errors.full_messages }, status: :unprocessable_entity
      end
    end

    # POST /test/login
    def login
      Rails.logger.info("TEST LOGIN called with params: #{params.inspect}")
      data = parse_request_data["user"] || parse_request_data
      user = User.find_by(username: data["username"])

      if user&.authenticate(data["password"])
        session[:user_id] = user.id
        Rails.logger.info("Login success via Test::UsersController for user=#{user.username} id=#{user.id}")
        USER_LOGINS.increment(labels: { status: "success" }) if defined?(USER_LOGINS)
        safe_update_last_login(user)
        render json: { id: user.id, username: user.username, message: "Login successful" }, status: :ok
      else
        Rails.logger.warn("Login failed for username=#{data['username']}")
        USER_LOGINS.increment(labels: { status: "failure" }) if defined?(USER_LOGINS)
        render json: { message: "Invalid username or password" }, status: :unauthorized
      end
    end

    # GET /test/logout
    def logout
      Rails.logger.info("TEST LOGOUT called for session_user_id=#{session[:user_id]}")
      session[:user_id] = nil
      render json: { message: "Logged out successfully" }, status: :ok
    end

    private

    # Helper: parse JSON body or fallback to params
    def parse_request_data
      JSON.parse(request.body.read) rescue params.to_unsafe_h
    end

    # Helper: update last_login safely
    def safe_update_last_login(user)
      user.update_columns(last_login: Time.current)
    rescue => e
      Rails.logger.error("Failed to update last_login for user=#{user.id}: #{e}")
    end
  end
end
