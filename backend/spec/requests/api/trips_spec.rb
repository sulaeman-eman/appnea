require "rails_helper"

RSpec.describe "Api::Trips" do
  def json = JSON.parse(response.body)

  it "lists published upcoming trips" do
    upcoming = create(:trip, published: true, start_date: Date.current + 10, end_date: Date.current + 11)
    create(:trip, published: false, start_date: Date.current + 10, end_date: Date.current + 11)
    create(:trip, published: true, start_date: Date.current - 10, end_date: Date.current - 9)

    get "/api/trips"
    expect(json["trips"].map { |t| t["id"] }).to eq([ upcoming.id ])
  end

  it "returns the description on show" do
    create(:trip, slug: "amed-camp", description: "Six days of coached depth training.")
    get "/api/trips/amed-camp"

    expect(response).to have_http_status(:ok)
    expect(json["trip"]["description"]).to eq("Six days of coached depth training.")
  end

  it "404s an unpublished trip" do
    create(:trip, slug: "draft-trip", published: false)
    get "/api/trips/draft-trip"
    expect(response).to have_http_status(:not_found)
  end
end
