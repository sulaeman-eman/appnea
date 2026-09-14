require "rails_helper"

RSpec.describe Course do
  it "derives a slug from the title on create" do
    course = create(:course, title: "AIDA 2 Freediver", slug: nil)
    expect(course.slug).to eq("aida-2-freediver")
  end

  it "keeps an explicitly given slug" do
    expect(create(:course, slug: "custom-slug").slug).to eq("custom-slug")
  end

  it "rejects a slug that is not lowercase and hyphenated" do
    course = build(:course, slug: "Not A Slug")
    expect(course).not_to be_valid
    expect(course.errors[:slug]).to include("must be lowercase and hyphenated")
  end

  it "rejects a duplicate slug" do
    create(:course, slug: "aida-2")
    expect(build(:course, slug: "aida-2")).not_to be_valid
  end

  it "rejects a negative price" do
    expect(build(:course, price_cents: -1)).not_to be_valid
  end

  it "scopes published courses" do
    published = create(:course, published: true)
    create(:course, published: false)
    expect(described_class.published).to contain_exactly(published)
  end

  it "refuses to be destroyed while schedules reference it" do
    course = create(:course)
    create(:schedule, course: course)
    expect(course.destroy).to be false
  end
end
