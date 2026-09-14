require "rails_helper"

RSpec.describe "Api::Bookings" do
  def json = JSON.parse(response.body)

  let(:user) { create(:user) }
  let(:course) { create(:course, price_cents: 450_000_00) }
  let(:schedule) { create(:schedule, course: course, capacity: 4) }
  let(:auth) { { "Authorization" => "Bearer #{Auth::Token.encode(user)}" } }

  describe "POST /api/bookings" do
    it "creates a pending booking and claims the seats" do
      post "/api/bookings", params: { booking: { schedule_id: schedule.id, participants: 2 } }, headers: auth

      expect(response).to have_http_status(:created)
      expect(json["booking"]).to include("status" => "pending", "participants" => 2)
      expect(json["booking"]["totalCents"]).to eq(450_000_00 * 2)
      expect(schedule.reload.seats_taken).to eq(2)
    end

    it "queues the receipt email" do
      expect {
        post "/api/bookings", params: { booking: { schedule_id: schedule.id, participants: 1 } }, headers: auth
      }.to have_enqueued_mail(BookingMailer, :received)
    end

    it "refuses to oversell" do
      post "/api/bookings", params: { booking: { schedule_id: schedule.id, participants: 5 } }, headers: auth

      expect(response).to have_http_status(:unprocessable_content)
      expect(json["detail"]).to eq("only 4 seat(s) left")
      expect(Booking.count).to eq(0)
    end

    it "401s without a token" do
      post "/api/bookings", params: { booking: { schedule_id: schedule.id, participants: 1 } }
      expect(response).to have_http_status(:unauthorized)
      expect(Booking.count).to eq(0)
    end

    it "404s an unknown schedule" do
      post "/api/bookings", params: { booking: { schedule_id: 0, participants: 1 } }, headers: auth
      expect(response).to have_http_status(:not_found)
    end
  end

  describe "GET /api/bookings" do
    it "returns only the caller's own bookings" do
      mine = create(:booking, user: user, schedule: schedule)
      create(:booking, user: create(:user), schedule: schedule)

      get "/api/bookings", headers: auth

      expect(response).to have_http_status(:ok)
      expect(json["bookings"].map { |b| b["id"] }).to eq([ mine.id ])
    end

    it "embeds the schedule and its course" do
      create(:booking, user: user, schedule: schedule)
      get "/api/bookings", headers: auth

      expect(json["bookings"].first["schedule"]["course"]["slug"]).to eq(course.slug)
    end

    it "401s without a token" do
      get "/api/bookings"
      expect(response).to have_http_status(:unauthorized)
    end
  end

  describe "DELETE /api/bookings/:id" do
    it "cancels the booking and releases its seats" do
      post "/api/bookings", params: { booking: { schedule_id: schedule.id, participants: 2 } }, headers: auth
      booking_id = json["booking"]["id"]

      delete "/api/bookings/#{booking_id}", headers: auth

      expect(response).to have_http_status(:ok)
      expect(json["booking"]["status"]).to eq("cancelled")
      expect(schedule.reload.seats_taken).to eq(0)
    end

    it "404s someone else's booking rather than cancelling it" do
      other = create(:booking, user: create(:user), schedule: schedule, participants: 1)

      delete "/api/bookings/#{other.id}", headers: auth

      expect(response).to have_http_status(:not_found)
      expect(other.reload).not_to be_cancelled
    end
  end
end
