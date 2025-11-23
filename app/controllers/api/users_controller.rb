module Api
  class UsersController < ApplicationController
    skip_before_action :verify_authenticity_token, only: [ :login, :register ]

    # POST /api/login
    def login
      username = params[:username]
      password = params[:password]

      user = User.find_by(username: username)

      if user&.authenticate(password)
        session[:user_id] = user.id

        if user.force_password_reset
          redirect_to "/change_password"
        else
          redirect_to root_path
        end
      else
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
        flash[:notice] = "Registration successful. Please log in."
        redirect_to login_path
      else
        flash[:alert] = user.errors.full_messages.join(", ")
        redirect_to register_path
      end
    end

    # POST /api/logout
    def logout
      session[:user_id] = nil
      render json: { message: "Logged out successfully" }
    end
  end
end
