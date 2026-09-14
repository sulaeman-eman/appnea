class Avo::Actions::ConfirmBooking < Avo::BaseAction
  self.name = "Confirm booking"
  self.message = "Confirm the selected booking(s)? The guest keeps their seats."
  self.standalone = false

  def handle(query:, fields:, current_user:, resource:, **args)
    confirmed = 0
    skipped = []

    query.each do |booking|
      if booking.cancelled?
        skipped << "##{booking.id} is cancelled"
        next
      end

      # Seats were already claimed by Bookings::Create when the booking was made,
      # so confirming only moves the status forward. No seat math here.
      booking.update!(status: :confirmed)
      BookingMailer.confirmed(booking).deliver_later
      confirmed += 1
    end

    succeed "Confirmed #{confirmed} booking(s)." if confirmed.positive?
    warn "Skipped: #{skipped.to_sentence}." if skipped.any?
    reload
  end
end
