module HasCoverImage
  extend ActiveSupport::Concern

  included do
    has_one_attached :cover_image do |attachable|
      # Two sizes cover every use: a card in a grid and a full-width header.
      # resize_to_fill crops to the exact ratio, so a grid never goes ragged
      # because someone uploaded a portrait photo.
      attachable.variant :card, resize_to_fill: [ 800, 533 ], format: :webp, saver: { quality: 80 }
      attachable.variant :hero, resize_to_fill: [ 1800, 900 ], format: :webp, saver: { quality: 82 }
    end
  end

  # Returns a path for the given variant, or nil when nothing is attached.
  # The variant is generated on first request, not here, so this stays cheap
  # enough to call from a serializer rendering a whole page of records.
  def cover_image_url(variant = :card)
    return nil unless cover_image.attached?

    Rails.application.routes.url_helpers.rails_storage_proxy_path(
      cover_image.variant(variant), only_path: true
    )
  rescue ActiveStorage::InvariableError
    Rails.application.routes.url_helpers.rails_storage_proxy_path(cover_image, only_path: true)
  end
end
