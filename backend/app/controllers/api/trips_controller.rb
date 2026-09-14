module Api
  class TripsController < BaseController
    def index
      scope = Trip.published.upcoming
      trips = paginate(scope)

      render json: {
        trips: TripBlueprint.render_as_hash(trips, locale: current_locale),
        meta: meta_for(scope, trips)
      }
    end

    def show
      trip = Trip.published.find_by!(slug: params[:slug])
      render json: { trip: TripBlueprint.render_as_hash(trip, view: :detail, locale: current_locale) }
    end
  end
end
