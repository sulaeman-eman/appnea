module Api
  class BaseController < ApplicationController
    rescue_from ActiveRecord::RecordNotFound, with: :not_found

    private

    # ?locale= wins, then Accept-Language, then English. Anything outside the
    # allowlist is ignored rather than passed through, so the value can be
    # dropped straight into a translations lookup.
    def current_locale
      @current_locale ||= begin
        requested = params[:locale].presence || preferred_locale_from_header
        Translatable::LOCALES.include?(requested) ? requested : Translatable::DEFAULT_LOCALE
      end
    end

    def preferred_locale_from_header
      request.headers["Accept-Language"].to_s
        .split(",")
        .map { |part| part.split(";").first.to_s.strip.downcase.split("-").first }
        .find { |tag| Translatable::LOCALES.include?(tag) }
    end

    def not_found
      render json: { error: "not_found" }, status: :not_found
    end

    # Present when the request carried a valid token, nil otherwise.
    # Endpoints that must not be reached anonymously call authenticate_user!.
    def current_user
      return @current_user if defined?(@current_user)

      @current_user = begin
        token = bearer_token
        token.present? ? User.find_by(id: Auth::Token.decode(token)["sub"]) : nil
      rescue Auth::Token::InvalidToken
        nil
      end
    end

    def authenticate_user!
      return if current_user

      render json: { error: "unauthorized" }, status: :unauthorized
    end

    def bearer_token
      header = request.headers["Authorization"].to_s
      header.start_with?("Bearer ") ? header.delete_prefix("Bearer ").strip : nil
    end

    # Pagination stays deliberately simple: the catalog is small, and a cursor
    # scheme would be unused complexity until it isn't.
    def paginate(scope)
      page = params[:page].to_i
      page = 1 if page < 1
      per_page = params[:per_page].to_i
      per_page = 20 if per_page < 1
      per_page = 100 if per_page > 100

      scope.limit(per_page).offset((page - 1) * per_page)
    end

    def meta_for(scope, _records)
      page = [ params[:page].to_i, 1 ].max
      { page: page, count: scope.count }
    end
  end
end
