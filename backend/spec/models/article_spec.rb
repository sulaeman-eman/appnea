require "rails_helper"

RSpec.describe Article do
  it "treats a nil published_at as a draft" do
    expect(create(:article, :draft)).not_to be_published
  end

  it "treats a future published_at as not yet published" do
    expect(create(:article, published_at: 1.day.from_now)).not_to be_published
  end

  it "scopes published articles newest first" do
    older = create(:article, published_at: 3.days.ago)
    newer = create(:article, published_at: 1.day.ago)
    create(:article, :draft)
    create(:article, published_at: 1.day.from_now)

    expect(described_class.published).to eq([ newer, older ])
  end
end
