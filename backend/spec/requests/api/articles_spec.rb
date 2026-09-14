require "rails_helper"

RSpec.describe "Api::Articles" do
  def json = JSON.parse(response.body)

  it "lists published articles newest first" do
    older = create(:article, published_at: 3.days.ago)
    newer = create(:article, published_at: 1.day.ago)
    create(:article, :draft)

    get "/api/articles"

    expect(json["articles"].map { |a| a["id"] }).to eq([ newer.id, older.id ])
  end

  it "omits the body from the index" do
    create(:article)
    get "/api/articles"
    expect(json["articles"].first).not_to have_key("body")
  end

  it "filters by category" do
    safety = create(:article, category: "safety")
    create(:article, category: "travel")

    get "/api/articles", params: { category: "safety" }
    expect(json["articles"].map { |a| a["id"] }).to eq([ safety.id ])
  end

  it "returns the body on show" do
    create(:article, slug: "never-dive-alone", body: "Full text here.")
    get "/api/articles/never-dive-alone"

    expect(response).to have_http_status(:ok)
    expect(json["article"]["body"]).to eq("Full text here.")
  end

  it "404s a draft rather than leaking it" do
    create(:article, :draft, slug: "unfinished")
    get "/api/articles/unfinished"
    expect(response).to have_http_status(:not_found)
  end

  it "404s an article scheduled for the future" do
    create(:article, slug: "embargoed", published_at: 1.day.from_now)
    get "/api/articles/embargoed"
    expect(response).to have_http_status(:not_found)
  end
end
