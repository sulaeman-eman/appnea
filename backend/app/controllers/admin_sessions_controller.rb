class AdminSessionsController < AdminController
  # Throttles credential stuffing against the admin panel.
  rate_limit to: 10, within: 3.minutes, only: :create,
    with: -> { redirect_to admin_login_path, alert: "Too many attempts. Wait a few minutes." }

  def new
    redirect_to Avo.configuration.root_path and return if current_admin_user

    render :new
  end

  def create
    user = User.find_by(email: params[:email].to_s.strip.downcase)

    # Only admins may sign in here. A correct password for a student account is
    # still a failed admin login, and says so in exactly the same words as a
    # wrong password, so this cannot be used to find out who the admins are.
    if user&.authenticate(params[:password].to_s) && user.admin?
      # Rotates the session id on privilege change, so a session fixated before
      # login cannot be reused afterwards.
      reset_session
      session[:admin_user_id] = user.id

      redirect_to(params[:next].presence&.then { |path| safe_redirect(path) } || Avo.configuration.root_path)
    else
      flash.now[:alert] = "Those details did not match an admin account."
      render :new, status: :unauthorized
    end
  end

  def destroy
    reset_session
    redirect_to admin_login_path, notice: "Signed out."
  end

  private

  # Only same-origin paths are honoured, so ?next= cannot bounce an admin to
  # another site after login.
  def safe_redirect(path)
    path.start_with?("/") && !path.start_with?("//") ? path : Avo.configuration.root_path
  end
end
