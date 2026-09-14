module Bookings
  # Cancels a booking and releases its seats back to the schedule.
  class Cancel
    Result = Struct.new(:success?, :booking, :error, keyword_init: true)

    def initialize(booking:)
      @booking = booking
    end

    def call
      return failure("booking is already cancelled") if @booking.cancelled?

      ActiveRecord::Base.transaction do
        schedule = @booking.schedule
        schedule.lock!

        @booking.update!(status: :cancelled)

        schedule.seats_taken = [ schedule.seats_taken - @booking.participants, 0 ].max
        # A cancellation reopens a schedule that had filled up, but never
        # resurrects one that was cancelled or already finished.
        schedule.status = :open if schedule.full? && schedule.seats_taken < schedule.capacity
        schedule.save!
      end

      Result.new(success?: true, booking: @booking)
    rescue ActiveRecord::RecordInvalid => e
      failure(e.record.errors.full_messages.to_sentence)
    end

    private

    def failure(message) = Result.new(success?: false, error: message)
  end
end
