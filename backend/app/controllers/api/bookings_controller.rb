module Api
  class BookingsController < BaseController
    before_action :authenticate_user!

    def index
      bookings = current_user.bookings
        .includes(schedule: %i[course instructor])
        .order(created_at: :desc)

      render json: { bookings: BookingBlueprint.render_as_hash(bookings) }
    end

    def create
      schedule = Schedule.find(params.dig(:booking, :schedule_id))

      result = Bookings::Create.new(
        user: current_user,
        schedule: schedule,
        participants: params.dig(:booking, :participants),
        notes: params.dig(:booking, :notes).to_s
      ).call

      if result.success?
        render json: { booking: BookingBlueprint.render_as_hash(result.booking) }, status: :created
      else
        render json: { error: "booking_failed", detail: result.error }, status: :unprocessable_content
      end
    end

    def destroy
      # Scoped to the current user's bookings, so one guest cannot cancel
      # another's by guessing an id.
      booking = current_user.bookings.find(params[:id])
      result = Bookings::Cancel.new(booking: booking).call

      if result.success?
        render json: { booking: BookingBlueprint.render_as_hash(booking.reload) }
      else
        render json: { error: "cancel_failed", detail: result.error }, status: :unprocessable_content
      end
    end
  end
end
