class TripBlueprint < Blueprinter::Base
  identifier :id

  fields :slug, :start_date, :end_date, :capacity, :price_cents, :currency

  field :title do |trip, options|
    trip.translated(:title, options[:locale])
  end

  field :destination do |trip, options|
    trip.translated(:destination, options[:locale])
  end

  field :summary do |trip, options|
    trip.translated(:summary, options[:locale])
  end

  field :available_locales do |trip|
    trip.translated_locales
  end

  field :cover_image_url do |trip|
    trip.cover_image_url(:card)
  end

  view :detail do
    field :description do |trip, options|
      trip.translated(:description, options[:locale])
    end

    field :cover_image_url do |trip|
      trip.cover_image_url(:hero)
    end
  end
end
