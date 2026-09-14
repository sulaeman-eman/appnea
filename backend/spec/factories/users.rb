FactoryBot.define do
  factory :user do
    sequence(:email) { |n| "diver#{n}@appnea.test" }
    name { "Test Diver" }
    password { "password123" }
    role { :student }

    trait :admin do
      role { :admin }
    end
  end
end
