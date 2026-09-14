FactoryBot.define do
  factory :article do
    sequence(:title) { |n| "Freediving Article #{n}" }
    excerpt { "A short summary." }
    body { "The full article body." }
    category { "technique" }
    published_at { 1.day.ago }

    trait :draft do
      published_at { nil }
    end
  end
end
