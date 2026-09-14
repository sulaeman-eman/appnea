module Bookings
  # Creates a booking and claims seats on the schedule.
  #
  # The seat claim runs inside a transaction that locks the schedule row first.
  # Two requests competing for the last seat therefore serialize: the second one
  # re-reads seats_taken after the first has committed and is rejected. Checking
  # availability without the lock would let both through.
  class Create
    Result = Struct.new(:success?, :booking, :error, keyword_init: true)

    def initialize(user:, schedule:, participants: 1, notes: "")
      @user = user
      @schedule = schedule
      @participants = participants.to_i
      @notes = notes.to_s
    end

    def call
      return failure("participants must be at least 1") if @participants < 1

      booking = nil

      ActiveRecord::Base.transaction do
        @schedule.lock!

        return failure("schedule is not open for booking") unless @schedule.open?
        return failure("only #{@schedule.seats_available} seat(s) left") if @participants > @schedule.seats_available

        booking = Booking.create!(
          user: @user,
          schedule: @schedule,
          participants: @participants,
          notes: @notes,
          status: :pending,
          total_cents: @schedule.course.price_cents * @participants
        )

        @schedule.seats_taken += @participants
        @schedule.status = :full if @schedule.seats_taken >= @schedule.capacity
        @schedule.save!
      end

      # Sent after the transaction commits, never inside it — a rolled back
      # booking must not produce a confirmation email.
      BookingMailer.received(booking).deliver_later

      Result.new(success?: true, booking: booking)
    rescue ActiveRecord::RecordInvalid => e
      failure(e.record.errors.full_messages.to_sentence)
    end

    private

    def failure(message) = Result.new(success?: false, error: message)
  end
end
