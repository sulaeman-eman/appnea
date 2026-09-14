require "rails_helper"

RSpec.describe Bookings::Create do
  let(:course) { create(:course, price_cents: 450_000_00) }
  let(:schedule) { create(:schedule, course: course, capacity: 4) }
  let(:user) { create(:user) }

  it "creates a pending booking and claims the seats" do
    result = described_class.new(user: user, schedule: schedule, participants: 2).call

    expect(result).to be_success
    expect(result.booking).to be_pending
    expect(result.booking.participants).to eq(2)
    expect(schedule.reload.seats_taken).to eq(2)
  end

  it "prices the booking from the course rate times the head count" do
    result = described_class.new(user: user, schedule: schedule, participants: 3).call
    expect(result.booking.total_cents).to eq(450_000_00 * 3)
  end

  it "marks the schedule full once the last seat goes" do
    described_class.new(user: user, schedule: schedule, participants: 4).call
    expect(schedule.reload).to be_full
  end

  it "refuses to book more seats than are available" do
    described_class.new(user: user, schedule: schedule, participants: 3).call
    result = described_class.new(user: create(:user), schedule: schedule.reload, participants: 2).call

    expect(result).not_to be_success
    expect(result.error).to eq("only 1 seat(s) left")
    expect(schedule.reload.seats_taken).to eq(3)
  end

  it "refuses to book a cancelled schedule" do
    schedule.update!(status: :cancelled)
    result = described_class.new(user: user, schedule: schedule, participants: 1).call

    expect(result).not_to be_success
    expect(result.error).to eq("schedule is not open for booking")
    expect(Booking.count).to eq(0)
  end

  it "rejects a participant count below one" do
    result = described_class.new(user: user, schedule: schedule, participants: 0).call

    expect(result).not_to be_success
    expect(result.error).to eq("participants must be at least 1")
  end
end
