class Schedule < ApplicationRecord
  enum :status, { open: 0, full: 1, cancelled: 2, done: 3 }, default: :open, validate: true

  belongs_to :course
  belongs_to :instructor, optional: true

  has_many :bookings, dependent: :restrict_with_error

  validates :start_date, :end_date, :capacity, presence: true
  validates :capacity, numericality: { greater_than: 0 }
  validates :seats_taken, numericality: { greater_than_or_equal_to: 0 }
  validate :end_date_after_start_date
  validate :seats_within_capacity

  scope :upcoming, -> { where(start_date: Date.current..).order(:start_date) }
  scope :bookable, -> { upcoming.where(status: :open) }

  def seats_available = capacity - seats_taken

  # Callers must not set seats_taken directly — go through Bookings::Create,
  # which takes a row lock first. See the note on the schedules check constraint.
  def sold_out? = seats_available <= 0

  # Ransack (used by Avo's search and filters) requires an explicit allowlist.
  def self.ransackable_attributes(_auth_object = nil)
    [ "id", "start_date", "end_date", "capacity", "seats_taken", "status", "created_at" ]
  end

  def self.ransackable_associations(_auth_object = nil)
    [ "course", "instructor", "bookings" ]
  end

  private

  def end_date_after_start_date
    return if start_date.blank? || end_date.blank?
    errors.add(:end_date, "must be on or after the start date") if end_date < start_date
  end

  def seats_within_capacity
    return if seats_taken.blank? || capacity.blank?
    errors.add(:seats_taken, "cannot exceed capacity") if seats_taken > capacity
  end
end
