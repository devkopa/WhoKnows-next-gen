module Test
  class UsersController < ApplicationController
    skip_before_action :verify_authenticity_token, only: [ :login, :register, :logout ]

    # POST /test/register
    def register
      data = JSON.parse(request.body.read) rescue {}
      user = User.new(
        username: data["username"],
        email: data["email"],
        password: data["password"],
        password_confirmation: data["password_confirmation"]
      )

      if user.save
        render json: { id: user.id, username: user.username, message: "Registration successful" }, status: :created
      else
        render json: { errors: user.errors.full_messages }, status: :unprocessable_entity
      end
    end

    # POST /test/login
    def login
      data = JSON.parse(request.body.read) rescue {}
      user = User.find_by(username: data["username"])

      if user&.authenticate(data["password"])
        session[:user_id] = user.id
        Rails.logger.info("Login success via Test::UsersController for user=#{user.username} id=#{user.id}")
        USER_LOGINS.increment(labels: { status: "success" })
        begin
          user.update_columns(last_login: Time.current)
        rescue => e
          Rails.logger.error("Failed to update last_login for user=#{user.id}: #{e}")
        end
        render json: { id: user.id, username: user.username, message: "Login successful" }
      else
        USER_LOGINS.increment(labels: { status: "failure" })
        render json: { message: "Invalid username or password" }, status: :unauthorized
      end
    end

    # GET /test/logout
    def logout
      session[:user_id] = nil
      render json: { message: "Logged out successfully" }, status: :ok
    end
  end
end
