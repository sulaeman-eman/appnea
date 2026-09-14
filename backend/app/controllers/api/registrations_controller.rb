module Api
  class RegistrationsController < BaseController
    def create
      user = User.new(signup_params.merge(role: :student))

      if user.save
        render json: { user: UserBlueprint.render_as_hash(user), token: Auth::Token.encode(user) }, status: :created
      else
        render json: { error: "validation_failed", details: user.errors.to_hash(true) }, status: :unprocessable_content
      end
    end

    private

    # role is deliberately not permitted — otherwise anyone could sign up as an
    # admin by adding one field to the request body.
    def signup_params
      params.require(:user).permit(:email, :password, :password_confirmation, :name)
    end
  end
end
