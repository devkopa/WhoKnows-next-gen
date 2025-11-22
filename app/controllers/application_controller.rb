class ApplicationController < ActionController::Base
  allow_browser versions: :modern

  before_action :force_password_reset_if_needed

  private

  def force_password_reset_if_needed
    return unless user_signed_in?
    return unless current_user.force_password_reset?

    # Undgå at låse API'et hvis du har en mobil/webapp
    return if request.format.json?

    # Undgå redirect-loop på password-siden
    allowed_paths = [
      change_password_path,
      update_password_path,
      destroy_user_session_path  # tillad logout
    ]

    return if allowed_paths.include?(request.path)

    redirect_to change_password_path, alert: "You need to change your password because of a security breach."
  end
end
