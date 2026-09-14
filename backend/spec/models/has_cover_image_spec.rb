require "rails_helper"
require Rails.root.join("lib/seeds/placeholder_image")
require "vips"

RSpec.describe HasCoverImage do
  let(:course) { create(:course) }

  def attach!(record)
    record.cover_image.attach(
      io: StringIO.new(Seeds::PlaceholderImage.jpeg(seed: "spec", width: 1200, height: 800)),
      filename: "spec.jpg",
      content_type: "image/jpeg"
    )
  end

  it "returns nil when nothing is attached" do
    expect(course.cover_image_url).to be_nil
  end

  it "returns a same-origin proxy path once attached" do
    attach!(course)
    url = course.cover_image_url(:card)

    # A proxy path, not a redirect path: the bytes come through our own origin
    # rather than sending the browser at the storage service.
    expect(url).to start_with("/rails/active_storage/representations/proxy/")
  end

  it "gives the card and hero variants different URLs" do
    attach!(course)
    expect(course.cover_image_url(:card)).not_to eq(course.cover_image_url(:hero))
  end

  # Reads the real bytes rather than the blob metadata, which is only filled in
  # by the analysis job and would make these assertions pass vacuously.
  def dimensions_of(variant)
    image = Vips::Image.new_from_buffer(variant.processed.image.download, "")
    [ image.width, image.height ]
  end

  it "processes the card variant to the declared size and format" do
    attach!(course)
    variant = course.cover_image.variant(:card)

    expect(variant.processed.image.blob.content_type).to eq("image/webp")
    expect(dimensions_of(variant)).to eq([ 800, 533 ])
  end

  it "processes the hero variant to its own size" do
    attach!(course)
    expect(dimensions_of(course.cover_image.variant(:hero))).to eq([ 1800, 900 ])
  end

  it "crops rather than distorts, so a portrait source still fills a landscape card" do
    course.cover_image.attach(
      io: StringIO.new(Seeds::PlaceholderImage.jpeg(seed: "tall", width: 600, height: 1600)),
      filename: "tall.jpg", content_type: "image/jpeg"
    )
    expect(dimensions_of(course.cover_image.variant(:card))).to eq([ 800, 533 ])
  end

  it "serialises the card variant on the index and the hero on the detail view" do
    attach!(course)

    index = CourseBlueprint.render_as_hash(course, locale: "en")
    detail = CourseBlueprint.render_as_hash(course, view: :detail, locale: "en")

    expect(index[:coverImageUrl]).to be_present
    expect(detail[:coverImageUrl]).to be_present
    expect(index[:coverImageUrl]).not_to eq(detail[:coverImageUrl])
  end
end
