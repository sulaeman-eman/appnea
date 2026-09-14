require "rails_helper"

RSpec.describe Bookings::Cancel do
  let(:schedule) { create(:schedule, capacity: 4) }
  let(:user) { create(:user) }

  def book(participants)
    Bookings::Create.new(user: user, schedule: schedule.reload, participants: participants).call.booking
  end

  it "cancels the booking and releases its seats" do
    booking = book(2)
    result = described_class.new(booking: booking).call

    expect(result).to be_success
    expect(booking.reload).to be_cancelled
    expect(schedule.reload.seats_taken).to eq(0)
  end

  it "reopens a schedule that had filled up" do
    booking = book(4)
    expect(schedule.reload).to be_full

    described_class.new(booking: booking).call
    expect(schedule.reload).to be_open
  end

  it "leaves a cancelled schedule cancelled" do
    booking = book(4)
    schedule.update_column(:status, Schedule.statuses[:cancelled])

    described_class.new(booking: booking).call
    expect(schedule.reload).to be_cancelled
  end

  it "refuses to cancel twice" do
    booking = book(1)
    described_class.new(booking: booking).call
    result = described_class.new(booking: booking.reload).call

    expect(result).not_to be_success
    expect(result.error).to eq("booking is already cancelled")
    expect(schedule.reload.seats_taken).to eq(0)
  end
end
