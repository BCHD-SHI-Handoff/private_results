class ApplicationController < ActionController::Base
  # Prevent CSRF attacks by raising an exception.
  # For APIs, you may want to use :null_session instead.
  protect_from_forgery with: :exception

  before_action :authenticate_user!

  def verify_is_admin
    (current_user.nil?) ? redirect_to(root_path) : (redirect_to(dashboards_path) unless current_user.admin?)
  end

  def after_sign_in_path_for(resource)
    dashboards_path
  end

  def after_sign_out_path_for(resource)
    dashboards_path
  end
end
