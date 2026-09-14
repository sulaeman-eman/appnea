class Booking < ApplicationRecord
  enum :status, { pending: 0, confirmed: 1, cancelled: 2 }, default: :pending, validate: true

  belongs_to :user
  belongs_to :schedule

  has_one :course, through: :schedule

  validates :participants, numericality: { greater_than: 0 }
  validates :total_cents, numericality: { greater_than_or_equal_to: 0 }

  scope :active, -> { where(status: %i[pending confirmed]) }

  def total = total_cents / 100.0

  # Ransack (used by Avo's search and filters) requires an explicit allowlist.
  def self.ransackable_attributes(_auth_object = nil)
    [ "id", "status", "participants", "total_cents", "payment_ref", "created_at" ]
  end

  def self.ransackable_associations(_auth_object = nil)
    [ "user", "schedule" ]
  end
end
