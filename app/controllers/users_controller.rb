class UsersController < ApplicationController
  skip_before_action :verify_authenticity_token, only: [ :login, :register ]

  def login
    data = JSON.parse(request.body.read) rescue {}
    user = User.find_by(username: data["username"])

    if user&.authenticate(data["password"])
      session[:user_id] = user.id
      render json: { id: user.id, username: user.username, message: "Login successful" }
    else
      render json: { message: "Invalid username or password" }, status: :unauthorized
    end
  end

  def index
    users = User.all
    render json: users, status: :ok
  end

  def show
    user = User.find(params[:id])
    render json: user, status: :ok
  rescue ActiveRecord::RecordNotFound
    render json: { error: "User not found" }, status: :not_found
  end

  def create
    data = request.request_parameters.presence || JSON.parse(request.body.read) rescue {}
    user = User.new(
      username: data["username"],
      email: data["email"],
      password: data["password"],
      password_confirmation: data["password_confirmation"]
    )

    if user.save
      render json: { id: user.id, username: user.username, message: "User created" }, status: :created
    else
      render json: { errors: user.errors.full_messages }, status: :unprocessable_entity
    end
  end

  def logout
    session[:user_id] = nil
    redirect_to root_path, notice: "Logged out successfully"
  end

  def register
    data = JSON.parse(request.body.read) rescue {}
    user = User.new(
      username: data["username"],
      email: data["email"],
      password: data["password"],
      password_confirmation: data["password_confirmation"]
    )

    if user.save
      render json: { id: user.id, username: user.username, message: "Registration successful" }
    else
      render json: { errors: user.errors.full_messages }, status: :unprocessable_entity
    end
  end
end
