class PasswordsController < ApplicationController
  before_action :authenticate_user!

  def edit
  end

  def update
    if current_user.update(password_params)
      current_user.update(force_password_reset: false)

      bypass_sign_in(current_user)

      redirect_to root_path, notice: "Your password has been changed"
    else
      flash.now[:alert] = "An error occurred. Try again."
      render :edit, status: :unprocessable_entity
    end
  end

  private

  def password_params
    params.require(:user).permit(:password, :password_confirmation)
  end
end
