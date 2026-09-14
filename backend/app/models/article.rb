class Article < ApplicationRecord
  has_one_attached :cover_image

  before_validation :generate_slug, on: :create

  validates :slug, presence: true, uniqueness: true,
    format: { with: /\A[a-z0-9]+(?:-[a-z0-9]+)*\z/, message: "must be lowercase and hyphenated" }
  validates :title, :category, presence: true

  scope :published, -> { where(published_at: ..Time.current).order(published_at: :desc) }

  def published? = published_at.present? && published_at <= Time.current

  # Ransack (used by Avo's search and filters) requires an explicit allowlist.
  def self.ransackable_attributes(_auth_object = nil)
    [ "id", "title", "slug", "category", "published_at", "created_at" ]
  end

  def self.ransackable_associations(_auth_object = nil)
    []
  end

  private

  def generate_slug
    self.slug = title.to_s.parameterize if slug.blank?
  end
end
