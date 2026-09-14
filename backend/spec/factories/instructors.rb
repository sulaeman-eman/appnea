FactoryBot.define do
  factory :instructor do
    sequence(:name) { |n| "Instructor #{n}" }
    bio { "Teaches freediving in Bali." }
    certifications { [ "AIDA Instructor" ] }
    display_order { 0 }
  end
end
