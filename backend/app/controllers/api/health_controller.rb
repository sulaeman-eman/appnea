module Api
  class HealthController < ApplicationController
    def show
      render json: {
        status: "ok",
        env: Rails.env,
        time: Time.current.iso8601
      }
    end
  end
end
