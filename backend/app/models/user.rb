class User < ApplicationRecord
  has_secure_password

  enum :role, { guest: 0, student: 1, instructor: 2, admin: 3 }, default: :student, validate: true

  has_one :instructor_profile, class_name: "Instructor", dependent: :nullify
  has_many :bookings, dependent: :destroy

  normalizes :email, with: ->(email) { email.strip.downcase }

  validates :email, presence: true, uniqueness: true, format: { with: URI::MailTo::EMAIL_REGEXP }
  validates :name, presence: true
  validates :password, length: { minimum: 8 }, allow_nil: true

  def admin? = role == "admin"

  # Ransack (used by Avo's search and filters) requires an explicit allowlist.
  def self.ransackable_attributes(_auth_object = nil)
    [ "id", "name", "email", "role", "created_at" ]
  end

  def self.ransackable_associations(_auth_object = nil)
    []
  end
end
