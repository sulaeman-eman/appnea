# Base for the handful of HTML endpoints that sign an admin into Avo.
#
# The JSON API inherits from ActionController::API and is stateless. This one
# needs cookies, a session, and CSRF protection, so it inherits from Base.
class AdminController < ActionController::Base
  protect_from_forgery with: :exception

  layout "admin"

  helper_method :current_admin_user

  def current_admin_user
    return @current_admin_user if defined?(@current_admin_user)

    @current_admin_user = begin
      user = User.find_by(id: session[:admin_user_id])
      user&.admin? ? user : nil
    end
  end
end
