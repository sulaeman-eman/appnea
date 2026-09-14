FactoryBot.define do
  factory :trip do
    sequence(:title) { |n| "Fun Dive Trip #{n}" }
    destination { "Nusa Penida, Bali" }
    start_date { Date.current + 21 }
    end_date { Date.current + 22 }
    capacity { 8 }
    price_cents { 1_500_000_00 }
    currency { "IDR" }
    summary { "Two days of guided fun diving." }
    description { "Boat, guide, and weights included." }
    published { true }
  end
end
