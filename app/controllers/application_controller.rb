class ApplicationController < ActionController::Base
  # Only allow modern browsers supporting webp images, web push, badges, import maps, CSS nesting, and CSS :has.
  allow_browser versions: :modern

  protected

  def ensure_admin
    redirect_to root_path, alert: "Access denied." unless current_user&.admin?
  end
end
