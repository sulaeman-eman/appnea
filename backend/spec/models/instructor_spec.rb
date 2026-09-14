require "rails_helper"

RSpec.describe Instructor do
  it "does not require a user account" do
    expect(build(:instructor, user: nil)).to be_valid
  end

  it "allows only one instructor profile per user" do
    user = create(:user)
    create(:instructor, user: user)
    expect { create(:instructor, user: user) }.to raise_error(ActiveRecord::RecordNotUnique)
  end

  it "stores certifications as an array" do
    instructor = create(:instructor, certifications: [ "AIDA Instructor", "EFR" ])
    expect(instructor.reload.certifications).to eq([ "AIDA Instructor", "EFR" ])
  end

  it "defaults certifications to an empty array" do
    expect(described_class.create!(name: "New Coach").certifications).to eq([])
  end

  it "orders by display_order then name" do
    third = create(:instructor, name: "Zara", display_order: 2)
    first = create(:instructor, name: "Adi", display_order: 1)
    second = create(:instructor, name: "Budi", display_order: 1)

    expect(described_class.ordered).to eq([ first, second, third ])
  end

  it "keeps its schedules when destroyed, detaching them instead" do
    instructor = create(:instructor)
    schedule = create(:schedule, instructor: instructor)

    instructor.destroy
    expect(schedule.reload.instructor_id).to be_nil
  end
end
