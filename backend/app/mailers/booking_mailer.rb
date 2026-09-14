class BookingMailer < ApplicationMailer
  def received(booking)
    @booking = booking
    @course = booking.schedule.course
    @schedule = booking.schedule

    mail to: booking.user.email, subject: "We received your booking for #{@course.title}"
  end

  def confirmed(booking)
    @booking = booking
    @course = booking.schedule.course
    @schedule = booking.schedule

    mail to: booking.user.email, subject: "Your #{@course.title} booking is confirmed"
  end
end
