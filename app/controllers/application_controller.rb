class ApplicationController < ActionController::Base
  allow_browser versions: :modern

  include Devise::Controllers::Helpers

  before_action :force_password_reset_if_needed

  private

  def force_password_reset_if_needed
    return unless respond_to?(:user_signed_in?) && user_signed_in?
    return unless current_user.force_password_reset?

    return if request.format.json?

    allowed_paths = [
      change_password_path,
      update_password_path,
      destroy_user_session_path # logout
    ]
    return if allowed_paths.include?(request.path)

    redirect_to change_password_path, alert: "You need to change your password because of a security breach."
  end
end
