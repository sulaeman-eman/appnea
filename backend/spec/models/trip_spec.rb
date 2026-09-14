require "rails_helper"

RSpec.describe Trip do
  it "derives a slug from the title on create" do
    expect(create(:trip, title: "Nusa Penida Fun Dive", slug: nil).slug).to eq("nusa-penida-fun-dive")
  end

  it "rejects an end date before the start date" do
    trip = build(:trip, start_date: Date.current + 10, end_date: Date.current + 9)
    expect(trip).not_to be_valid
    expect(trip.errors[:end_date]).to include("must be on or after the start date")
  end

  it "rejects a duplicate slug" do
    create(:trip, slug: "amed-camp")
    expect(build(:trip, slug: "amed-camp")).not_to be_valid
  end

  it "scopes published trips" do
    published = create(:trip, published: true)
    create(:trip, published: false)
    expect(described_class.published).to contain_exactly(published)
  end

  it "scopes upcoming trips by start date" do
    soon = create(:trip, start_date: Date.current + 5, end_date: Date.current + 6)
    later = create(:trip, start_date: Date.current + 30, end_date: Date.current + 31)
    create(:trip, start_date: Date.current - 5, end_date: Date.current - 4)

    expect(described_class.upcoming).to eq([ soon, later ])
  end
end
