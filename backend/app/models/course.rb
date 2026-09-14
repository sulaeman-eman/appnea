class Course < ApplicationRecord
  enum :agency, { aida: 0, ssi: 1, molchanovs: 2 }, default: :aida, validate: true

  has_many :schedules, dependent: :restrict_with_error
  has_one_attached :cover_image

  before_validation :generate_slug, on: :create

  validates :slug, presence: true, uniqueness: true,
    format: { with: /\A[a-z0-9]+(?:-[a-z0-9]+)*\z/, message: "must be lowercase and hyphenated" }
  validates :title, :level, presence: true
  validates :duration_days, numericality: { greater_than: 0 }
  validates :price_cents, numericality: { greater_than_or_equal_to: 0 }
  validates :depth_target_m, numericality: { greater_than: 0 }, allow_nil: true

  scope :published, -> { where(published: true) }

  def price = price_cents / 100.0

  # Ransack (used by Avo's search and filters) requires an explicit allowlist.
  def self.ransackable_attributes(_auth_object = nil)
    [ "id", "title", "slug", "agency", "level", "price_cents", "published", "created_at" ]
  end

  def self.ransackable_associations(_auth_object = nil)
    [ "schedules" ]
  end

  private

  def generate_slug
    self.slug = title.to_s.parameterize if slug.blank?
  end
end
