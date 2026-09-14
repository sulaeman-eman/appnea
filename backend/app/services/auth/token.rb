module Auth
  # Issues and verifies the JWTs handed to the Express BFF.
  #
  # The signing key is derived from secret_key_base rather than read straight
  # from it, so a leak of one derived key does not hand over the master secret
  # that also protects sessions and Active Record encryption.
  module Token
    ALGORITHM = "HS256".freeze
    TTL = 7.days
    KEY_SALT = "appnea/api-jwt".freeze

    class InvalidToken < StandardError; end

    module_function

    def encode(user)
      now = Time.current.to_i

      JWT.encode(
        {
          sub: user.id,
          role: user.role,
          iat: now,
          exp: (Time.current + TTL).to_i
        },
        secret,
        ALGORITHM
      )
    end

    # Returns the payload, or raises InvalidToken. Signature, expiry, and the
    # presence of a subject are all checked — an unverified decode would accept
    # a token any client could forge.
    def decode(token)
      payload, = JWT.decode(token, secret, true, algorithm: ALGORITHM, verify_expiration: true)
      raise InvalidToken, "missing subject" if payload["sub"].blank?

      payload
    rescue JWT::DecodeError, JWT::ExpiredSignature => e
      raise InvalidToken, e.message
    end

    def secret
      Rails.application.key_generator.generate_key(KEY_SALT, 32)
    end
  end
end
