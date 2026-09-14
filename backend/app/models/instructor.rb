class Instructor < ApplicationRecord
  belongs_to :user, optional: true

  has_many :schedules, dependent: :nullify
  has_one_attached :photo

  validates :name, presence: true

  scope :ordered, -> { order(:display_order, :name) }

  # Ransack (used by Avo's search and filters) requires an explicit allowlist.
  def self.ransackable_attributes(_auth_object = nil)
    [ "id", "name", "display_order", "created_at" ]
  end

  def self.ransackable_associations(_auth_object = nil)
    [ "user", "schedules" ]
  end
end
