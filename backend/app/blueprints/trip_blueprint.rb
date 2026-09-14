class TripBlueprint < Blueprinter::Base
  identifier :id

  fields :slug, :title, :destination, :start_date, :end_date, :capacity,
    :price_cents, :currency, :summary

  field :cover_image_url do |trip|
    trip.cover_image.attached? ? Rails.application.routes.url_helpers.rails_blob_path(trip.cover_image, only_path: true) : nil
  end

  view :detail do
    field :description
  end
end
