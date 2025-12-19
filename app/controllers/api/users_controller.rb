module Api
  class UsersController < ApplicationController
    skip_before_action :verify_authenticity_token, only: [ :login, :register, :logout ]

    # POST /api/login
    def login
      user = User.find_by(username: params[:username])
      if user&.authenticate(params[:password])
        session[:user_id] = user.id
        Rails.logger.info("Login success via Api::UsersController for user=#{user.username} id=#{user.id}")
        USER_LOGINS.increment(labels: { status: "success" })
        # Update last_login timestamp
        begin
          user.update_columns(last_login: Time.current)
        rescue => e
          Rails.logger.error("Failed to update last_login for user=#{user.id}: #{e}")
        end
        if user.force_password_reset
          redirect_to "/change_password"
        else
          redirect_to root_path
        end
      else
        USER_LOGINS.increment(labels: { status: "failure" })
        flash[:alert] = "Wrong username or password"
        redirect_to login_path
      end
    end

    # POST /api/register
    def register
      user = User.new(
        username: params[:username],
        email: params[:email],
        password: params[:password],
        password_confirmation: params[:password_confirmation]
      )

      if user.save
        # Gem success-besked i flash
        flash[:notice] = "Registration successful. You can now log in."
        # Redirect til /register (ikke render)
        redirect_to register_path
      else
        flash[:alert] = user.errors.full_messages.join(", ")
        redirect_to register_path
      end
    end

    # GET /logout (browser)
    # GET /api/logout (API)
    def logout
      session[:user_id] = nil

      respond_to do |format|
        format.html { redirect_to login_path }
        format.json { render json: { message: "Logged out successfully" } }
      end
    end
  end
end
