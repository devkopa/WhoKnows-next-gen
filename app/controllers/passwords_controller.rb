class PasswordsController < ApplicationController
  before_action :require_authentication

  def edit
    flash.clear
    @user = User.find(session[:user_id])
  end

  def update
    @user = User.find(session[:user_id])

    if @user.update(password_params.merge(force_password_reset: false))
      begin
        PASSWORD_CHANGES.increment(labels: { status: "success" })
      rescue => e
        Rails.logger.warn("Could not increment PASSWORD_CHANGES: #{e.message}")
      end
      flash.now[:notice] = "Password changed successfully."
      Rails.logger.info("Password changed for user=#{@user.username} id=#{@user.id}")
      render :edit
    else
      begin
        PASSWORD_CHANGES.increment(labels: { status: "failure" })
      rescue => e
        Rails.logger.warn("Could not increment PASSWORD_CHANGES: #{e.message}")
      end
      flash.now[:alert] = "Something went wrong. Please check the form."
      render :edit
    end
  end

  private

  def require_authentication
    redirect_to login_path unless session[:user_id]
  end

  def password_params
    params.require(:user).permit(:password, :password_confirmation)
  end
end
