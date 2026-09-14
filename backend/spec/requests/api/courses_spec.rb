require "rails_helper"

RSpec.describe "Api::Courses" do
  def json = JSON.parse(response.body)

  describe "GET /api/courses" do
    it "returns only published courses" do
      published = create(:course, published: true, title: "AIDA 2 Freediver")
      create(:course, published: false, title: "Hidden Course")

      get "/api/courses"

      expect(response).to have_http_status(:ok)
      expect(json["courses"].map { |c| c["title"] }).to eq([ published.title ])
    end

    it "emits camelCase keys" do
      create(:course, depth_target_m: 30, duration_days: 4)
      get "/api/courses"

      course = json["courses"].first
      expect(course).to include("depthTargetM" => 30, "durationDays" => 4)
      expect(course).to have_key("priceCents")
      expect(course).not_to have_key("depth_target_m")
    end

    it "omits the long description from the index" do
      create(:course)
      get "/api/courses"
      expect(json["courses"].first).not_to have_key("description")
    end

    it "paginates" do
      create_list(:course, 3)
      get "/api/courses", params: { per_page: 2 }

      expect(json["courses"].size).to eq(2)
      expect(json["meta"]).to eq("page" => 1, "count" => 3)
    end

    it "caps per_page at 100" do
      create(:course)
      get "/api/courses", params: { per_page: 5000 }
      expect(response).to have_http_status(:ok)
    end
  end

  describe "GET /api/courses/:slug" do
    it "returns the course with its bookable schedules" do
      course = create(:course, slug: "aida-2")
      bookable = create(:schedule, course: course, status: :open, start_date: Date.current + 10, end_date: Date.current + 12)
      create(:schedule, course: course, status: :cancelled, start_date: Date.current + 10, end_date: Date.current + 12)

      get "/api/courses/aida-2"

      expect(response).to have_http_status(:ok)
      expect(json["course"]["description"]).to be_present
      expect(json["course"]["schedules"].map { |s| s["id"] }).to eq([ bookable.id ])
    end

    it "includes seat availability on each schedule" do
      course = create(:course, slug: "aida-3")
      create(:schedule, course: course, capacity: 4, seats_taken: 1)

      get "/api/courses/aida-3"

      schedule = json["course"]["schedules"].first
      expect(schedule).to include("seatsAvailable" => 3, "seatsTaken" => 1, "capacity" => 4)
    end

    it "404s an unpublished course" do
      create(:course, slug: "secret", published: false)
      get "/api/courses/secret"

      expect(response).to have_http_status(:not_found)
      expect(json).to eq("error" => "not_found")
    end

    it "404s an unknown slug" do
      get "/api/courses/nope"
      expect(response).to have_http_status(:not_found)
    end
  end
end
