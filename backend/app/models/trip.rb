class Trip < ApplicationRecord
  has_one_attached :cover_image

  before_validation :generate_slug, on: :create

  validates :slug, presence: true, uniqueness: true,
    format: { with: /\A[a-z0-9]+(?:-[a-z0-9]+)*\z/, message: "must be lowercase and hyphenated" }
  validates :title, :destination, :start_date, :end_date, presence: true
  validates :capacity, numericality: { greater_than: 0 }
  validates :price_cents, numericality: { greater_than_or_equal_to: 0 }
  validate :end_date_after_start_date

  scope :published, -> { where(published: true) }
  scope :upcoming, -> { where(start_date: Date.current..).order(:start_date) }

  def price = price_cents / 100.0

  # Ransack (used by Avo's search and filters) requires an explicit allowlist.
  def self.ransackable_attributes(_auth_object = nil)
    [ "id", "title", "slug", "destination", "start_date", "price_cents", "published", "created_at" ]
  end

  def self.ransackable_associations(_auth_object = nil)
    []
  end

  private

  def generate_slug
    self.slug = title.to_s.parameterize if slug.blank?
  end

  def end_date_after_start_date
    return if start_date.blank? || end_date.blank?
    errors.add(:end_date, "must be on or after the start date") if end_date < start_date
  end
end
