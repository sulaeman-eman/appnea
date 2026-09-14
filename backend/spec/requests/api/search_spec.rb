require "rails_helper"

RSpec.describe "Api::Search" do
  def json = JSON.parse(response.body)

  let!(:course) do
    create(:course, title: "AIDA 3 Advanced Freediver", published: true,
      summary: "Free immersion and mouthfill equalisation to 30 m.")
  end
  let!(:article) do
    create(:article, title: "Equalisation for Beginners", category: "technique",
      body: "Frenzel uses the tongue as a piston.", published_at: 1.day.ago)
  end

  it "finds a course by a word in its summary" do
    get "/api/search", params: { q: "mouthfill" }

    expect(response).to have_http_status(:ok)
    expect(json["courses"].map { |c| c["id"] }).to eq([ course.id ])
    expect(json["total"]).to eq(1)
  end

  it "finds an article by a word in its body" do
    get "/api/search", params: { q: "frenzel" }
    expect(json["articles"].map { |a| a["id"] }).to eq([ article.id ])
  end

  it "matches across both types at once" do
    get "/api/search", params: { q: "equalisation" }

    expect(json["courses"]).not_to be_empty
    expect(json["articles"]).not_to be_empty
    expect(json["total"]).to eq(2)
  end

  it "stems, so a plural finds the singular" do
    get "/api/search", params: { q: "beginners" }
    expect(json["articles"]).not_to be_empty
  end

  it "supports a quoted phrase" do
    get "/api/search", params: { q: '"free immersion"' }
    expect(json["courses"].map { |c| c["id"] }).to eq([ course.id ])
  end

  it "returns nothing for a blank query rather than everything" do
    get "/api/search", params: { q: "   " }

    expect(json["courses"]).to be_empty
    expect(json["articles"]).to be_empty
    expect(json["total"]).to eq(0)
  end

  it "returns nothing for a query that matches nothing" do
    get "/api/search", params: { q: "helicopter" }
    expect(json["total"]).to eq(0)
  end

  it "treats a SQL fragment as a search term, not as SQL" do
    get "/api/search", params: { q: "'); DROP TABLE courses; --" }

    expect(response).to have_http_status(:ok)
    expect(Course.count).to eq(1)
  end

  it "hides unpublished records from results" do
    create(:course, title: "Secret Mouthfill Masterclass", published: false)
    get "/api/search", params: { q: "mouthfill" }

    expect(json["courses"].map { |c| c["title"] }).to eq([ course.title ])
  end

  it "hides drafts from results" do
    create(:article, title: "Draft Frenzel Notes", published_at: nil)
    get "/api/search", params: { q: "frenzel" }

    expect(json["articles"].map { |a| a["id"] }).to eq([ article.id ])
  end

  it "ranks a title match above a body-only match" do
    body_only = create(:article, title: "Trip Report", body: "We practised frenzel all week.",
      published_at: 2.days.ago)
    titled = create(:article, title: "Frenzel Drills", body: "Nothing much.", published_at: 3.days.ago)

    get "/api/search", params: { q: "frenzel" }
    ids = json["articles"].map { |a| a["id"] }

    expect(ids.index(titled.id)).to be < ids.index(body_only.id)
  end
end
