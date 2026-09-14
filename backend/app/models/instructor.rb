class Instructor < ApplicationRecord
  belongs_to :user, optional: true

  has_many :schedules, dependent: :nullify
  has_one_attached :photo do |attachable|
    attachable.variant :avatar, resize_to_fill: [ 600, 600 ], format: :webp, saver: { quality: 80 }
  end


  validates :name, presence: true

  def photo_url
    return nil unless photo.attached?

    Rails.application.routes.url_helpers.rails_storage_proxy_path(
      photo.variant(:avatar), only_path: true
    )
  end

  scope :ordered, -> { order(:display_order, :name) }

  # Ransack (used by Avo's search and filters) requires an explicit allowlist.
  def self.ransackable_attributes(_auth_object = nil)
    [ "id", "name", "display_order", "created_at" ]
  end

  def self.ransackable_associations(_auth_object = nil)
    [ "user", "schedules" ]
  end
end
