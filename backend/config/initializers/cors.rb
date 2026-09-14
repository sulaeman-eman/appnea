# The browser never calls Rails directly — the Express BFF proxies every request
# server-side, so these origins only matter for local development tooling and any
# future first-party client that talks to the API from the browser.
Rails.application.config.middleware.insert_before 0, Rack::Cors do
  allow do
    origins ENV.fetch("CORS_ORIGINS", "http://localhost:5173").split(",")

    resource "/api/*",
      headers: :any,
      methods: %i[get post put patch delete options head],
      credentials: false
  end
end
