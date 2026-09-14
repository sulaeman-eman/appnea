require "rails_helper"

RSpec.describe "Api::Schedules" do
  def json = JSON.parse(response.body)

  let(:course) { create(:course, published: true) }

  it "lists upcoming open schedules for published courses" do
    bookable = create(:schedule, course: course, status: :open, start_date: Date.current + 7, end_date: Date.current + 9)
    create(:schedule, course: course, status: :full, start_date: Date.current + 7, end_date: Date.current + 9)
    create(:schedule, course: create(:course, published: false), start_date: Date.current + 7, end_date: Date.current + 9)

    get "/api/schedules"

    expect(response).to have_http_status(:ok)
    expect(json["schedules"].map { |s| s["id"] }).to eq([ bookable.id ])
  end

  it "embeds the course on each schedule" do
    create(:schedule, course: course)
    get "/api/schedules"

    expect(json["schedules"].first["course"]).to include("slug" => course.slug, "title" => course.title)
  end

  it "filters by course_id" do
    wanted = create(:schedule, course: course)
    create(:schedule, course: create(:course, published: true))

    get "/api/schedules", params: { course_id: course.id }
    expect(json["schedules"].map { |s| s["id"] }).to eq([ wanted.id ])
  end

  it "filters by a from date" do
    create(:schedule, course: course, start_date: Date.current + 5, end_date: Date.current + 6)
    later = create(:schedule, course: course, start_date: Date.current + 40, end_date: Date.current + 41)

    get "/api/schedules", params: { from: (Date.current + 30).iso8601 }
    expect(json["schedules"].map { |s| s["id"] }).to eq([ later.id ])
  end

  it "rejects a malformed from date" do
    get "/api/schedules", params: { from: "not-a-date" }

    expect(response).to have_http_status(:bad_request)
    expect(json["error"]).to eq("invalid_date")
  end
end
