class Avo::Actions::CancelBooking < Avo::BaseAction
  self.name = "Cancel booking"
  self.message = "Cancel the selected booking(s)? Their seats go back to the schedule."
  self.standalone = false

  def handle(query:, fields:, current_user:, resource:, **args)
    cancelled = 0
    failures = []

    query.each do |booking|
      # Bookings::Cancel takes the schedule row lock and releases the seats.
      result = Bookings::Cancel.new(booking: booking).call
      result.success? ? cancelled += 1 : failures << "##{booking.id}: #{result.error}"
    end

    succeed "Cancelled #{cancelled} booking(s)." if cancelled.positive?
    error failures.to_sentence if failures.any?
    reload
  end
end
