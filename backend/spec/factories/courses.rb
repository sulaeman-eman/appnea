FactoryBot.define do
  factory :course do
    sequence(:title) { |n| "AIDA #{n} Freediver" }
    agency { :aida }
    level { "Level 1" }
    depth_target_m { 20 }
    duration_days { 3 }
    price_cents { 450_000_00 }
    currency { "IDR" }
    summary { "Entry level freediving certification." }
    description { "Three days of theory, pool, and depth sessions." }
    published { true }
  end
end
