class PasswordsController < ApplicationController
  def edit
    redirect_to login_path unless session[:user_id]
    flash.clear
    @user = User.find(session[:user_id])
  end

  def update
    @user = User.find(session[:user_id])

    if @user.update(password_params.merge(force_password_reset: false))
      flash.now[:notice] = "Password changed successfully."
      render :edit
    else
      flash.now[:alert] = "Something went wrong. Please check the form."
      render :edit
    end
  end

  private

  def password_params
    params.require(:user).permit(:password, :password_confirmation)
  end
end
