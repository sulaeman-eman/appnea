require "rails_helper"

# These examples run real concurrent threads, so each needs its own database
# connection and its own committed data — a surrounding test transaction would
# hide the rows from the other threads and defeat the point.
RSpec.describe Bookings::Create, "under concurrency" do
  self.use_transactional_tests = false

  let!(:course) { create(:course, price_cents: 100_00) }
  let!(:schedule) { create(:schedule, course: course, capacity: 4, seats_taken: 0) }
  let!(:users) { create_list(:user, 8) }

  after do
    Booking.delete_all
    Schedule.delete_all
    Course.delete_all
    Instructor.delete_all
    User.delete_all
  end

  it "never sells more seats than the capacity when 8 people book at once" do
    barrier = Concurrent::CountDownLatch.new(1) if defined?(Concurrent)

    results = users.map do |user|
      Thread.new do
        ActiveRecord::Base.connection_pool.with_connection do
          barrier&.wait(5)
          described_class.new(user: user, schedule: Schedule.find(schedule.id), participants: 1).call
        end
      end
    end

    barrier&.count_down
    outcomes = results.map(&:value)

    successes = outcomes.count(&:success?)
    expect(successes).to eq(4)
    expect(outcomes.count { |o| !o.success? }).to eq(4)

    expect(schedule.reload.seats_taken).to eq(4)
    expect(Booking.count).to eq(4)
    expect(schedule).to be_full
  end

  it "keeps seats_taken in step with the bookings when multi-seat requests race" do
    # Two requests for 3 seats each against a capacity of 4: exactly one can win.
    pair = users.first(2).map do |user|
      Thread.new do
        ActiveRecord::Base.connection_pool.with_connection do
          described_class.new(user: user, schedule: Schedule.find(schedule.id), participants: 3).call
        end
      end
    end

    outcomes = pair.map(&:value)

    expect(outcomes.count(&:success?)).to eq(1)
    expect(schedule.reload.seats_taken).to eq(3)
    expect(Booking.sum(:participants)).to eq(3)
  end
end
