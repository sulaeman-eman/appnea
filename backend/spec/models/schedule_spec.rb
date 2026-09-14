require "rails_helper"

RSpec.describe Schedule do
  it "reports the seats still available" do
    schedule = create(:schedule, capacity: 4, seats_taken: 1)
    expect(schedule.seats_available).to eq(3)
  end

  it "is sold out once seats_taken reaches capacity" do
    expect(create(:schedule, capacity: 2, seats_taken: 2)).to be_sold_out
  end

  it "rejects an end date before the start date" do
    schedule = build(:schedule, start_date: Date.current + 10, end_date: Date.current + 9)
    expect(schedule).not_to be_valid
    expect(schedule.errors[:end_date]).to include("must be on or after the start date")
  end

  it "rejects seats_taken above capacity at the model level" do
    expect(build(:schedule, capacity: 2, seats_taken: 3)).not_to be_valid
  end

  it "rejects seats_taken above capacity at the database level too" do
    schedule = create(:schedule, capacity: 2, seats_taken: 0)
    expect {
      schedule.update_column(:seats_taken, 5)
    }.to raise_error(ActiveRecord::StatementInvalid, /schedules_seats_within_capacity/)
  end

  it "lists only upcoming open schedules as bookable" do
    bookable = create(:schedule, start_date: Date.current + 5, end_date: Date.current + 7, status: :open)
    create(:schedule, start_date: Date.current + 5, end_date: Date.current + 7, status: :cancelled)
    create(:schedule, start_date: Date.current - 5, end_date: Date.current - 3, status: :open)

    expect(described_class.bookable).to contain_exactly(bookable)
  end
end
