require "rails_helper"

RSpec.describe Booking do
  it "starts out pending" do
    expect(create(:booking)).to be_pending
  end

  it "rejects a participant count below one" do
    expect(build(:booking, participants: 0)).not_to be_valid
  end

  it "rejects a participant count below one at the database level too" do
    booking = create(:booking)
    expect {
      booking.update_column(:participants, 0)
    }.to raise_error(ActiveRecord::StatementInvalid, /bookings_participants_positive/)
  end

  it "reaches the course through the schedule" do
    course = create(:course)
    booking = create(:booking, schedule: create(:schedule, course: course))
    expect(booking.course).to eq(course)
  end

  it "scopes pending and confirmed bookings as active" do
    pending_booking = create(:booking, status: :pending)
    confirmed = create(:booking, status: :confirmed)
    create(:booking, status: :cancelled)

    expect(described_class.active).to contain_exactly(pending_booking, confirmed)
  end

  it "leaves payment_ref blank until a gateway is wired up" do
    expect(create(:booking).payment_ref).to be_nil
  end
end
