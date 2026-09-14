module Api
  class SessionsController < BaseController
    # Throttles credential stuffing. Rails 8 keys this on the client IP by
    # default and stores counters in Rails.cache.
    rate_limit to: 10, within: 3.minutes, only: :create,
      with: -> { render json: { error: "too_many_attempts" }, status: :too_many_requests }

    def create
      user = User.find_by(email: params.dig(:session, :email).to_s.strip.downcase)

      if user&.authenticate(params.dig(:session, :password).to_s)
        render json: { user: UserBlueprint.render_as_hash(user), token: Auth::Token.encode(user) }
      else
        # Deliberately identical whether the email is unknown or the password is
        # wrong, so the endpoint cannot be used to enumerate accounts.
        render json: { error: "invalid_credentials" }, status: :unauthorized
      end
    end
  end
end
