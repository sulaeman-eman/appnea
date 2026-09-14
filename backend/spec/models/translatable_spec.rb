require "rails_helper"

RSpec.describe Translatable do
  let(:course) do
    create(:course, title: "AIDA 2 Freediver", summary: "Your first certification.", level: "Beginner",
      translations: { "id" => { "title" => "AIDA 2 Penyelam Bebas", "summary" => "Sertifikasi pertamamu." } })
  end

  it "returns the base column for the default locale" do
    expect(course.translated(:title, "en")).to eq("AIDA 2 Freediver")
  end

  it "returns the override for a translated locale" do
    expect(course.translated(:title, "id")).to eq("AIDA 2 Penyelam Bebas")
  end

  it "falls back to the base column when a field is untranslated" do
    # level has no Indonesian override, so a partly translated row still renders.
    expect(course.translated(:level, "id")).to eq("Beginner")
  end

  it "falls back when the override is present but blank" do
    course.update!(translations: { "id" => { "title" => "  " } })
    expect(course.translated(:title, "id")).to eq("AIDA 2 Freediver")
  end

  it "falls back for a locale with no translations at all" do
    expect(course.translated(:title, "fr")).to eq("AIDA 2 Freediver")
  end

  it "ignores overrides for fields that were never declared translatable" do
    course.update!(translations: { "id" => { "slug" => "sneaky-slug" } })
    expect(course.translated(:slug, "id")).to eq(course.slug)
  end

  it "lists which locales the record has been translated into" do
    expect(course.translated_locales).to eq([ "id" ])
  end

  it "defaults translations to an empty hash" do
    expect(create(:course).translations).to eq({})
  end
end
