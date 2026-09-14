require "rails_helper"

RSpec.describe "Api::Instructors" do
  def json = JSON.parse(response.body)

  it "lists instructors in display order" do
    second = create(:instructor, name: "Zara", display_order: 2)
    first = create(:instructor, name: "Adi", display_order: 1)

    get "/api/instructors"

    expect(response).to have_http_status(:ok)
    expect(json["instructors"].map { |i| i["id"] }).to eq([ first.id, second.id ])
  end

  it "includes certifications and bio" do
    create(:instructor, certifications: [ "AIDA Instructor" ], bio: "Teaches in Amed.")
    get "/api/instructors"

    expect(json["instructors"].first).to include(
      "certifications" => [ "AIDA Instructor" ],
      "bio" => "Teaches in Amed."
    )
  end
end
