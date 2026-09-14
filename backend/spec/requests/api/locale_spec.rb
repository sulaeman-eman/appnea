require "rails_helper"

RSpec.describe "API locale handling" do
  def json = JSON.parse(response.body)

  let!(:course) do
    create(:course, slug: "aida-2", title: "AIDA 2 Freediver", level: "Beginner", published: true,
      translations: { "id" => { "title" => "AIDA 2 Penyelam Bebas" } })
  end

  it "serves English by default" do
    get "/api/courses"
    expect(json["courses"].first["title"]).to eq("AIDA 2 Freediver")
  end

  it "honours ?locale=id" do
    get "/api/courses", params: { locale: "id" }
    expect(json["courses"].first["title"]).to eq("AIDA 2 Penyelam Bebas")
  end

  it "honours Accept-Language" do
    get "/api/courses", headers: { "Accept-Language" => "id-ID,id;q=0.9,en;q=0.8" }
    expect(json["courses"].first["title"]).to eq("AIDA 2 Penyelam Bebas")
  end

  it "lets ?locale= win over Accept-Language" do
    get "/api/courses", params: { locale: "en" }, headers: { "Accept-Language" => "id" }
    expect(json["courses"].first["title"]).to eq("AIDA 2 Freediver")
  end

  it "falls back to English for an unsupported locale" do
    get "/api/courses", params: { locale: "fr" }
    expect(json["courses"].first["title"]).to eq("AIDA 2 Freediver")
  end

  it "falls back to English for a junk locale rather than failing" do
    get "/api/courses", params: { locale: "../../etc/passwd" }

    expect(response).to have_http_status(:ok)
    expect(json["courses"].first["title"]).to eq("AIDA 2 Freediver")
  end

  it "still falls back per field on a partly translated record" do
    get "/api/courses", params: { locale: "id" }
    expect(json["courses"].first["level"]).to eq("Beginner")
  end

  it "reports which locales a record is available in" do
    get "/api/courses"
    expect(json["courses"].first["availableLocales"]).to eq([ "id" ])
  end

  it "applies the locale on the detail endpoint too" do
    get "/api/courses/aida-2", params: { locale: "id" }
    expect(json["course"]["title"]).to eq("AIDA 2 Penyelam Bebas")
  end
end
