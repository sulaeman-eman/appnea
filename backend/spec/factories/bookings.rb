FactoryBot.define do
  factory :booking do
    user
    schedule
    participants { 1 }
    status { :pending }
    total_cents { 450_000_00 }
    notes { "" }
  end
end
