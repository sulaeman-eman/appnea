FactoryBot.define do
  factory :schedule do
    course
    instructor
    start_date { Date.current + 14 }
    end_date { Date.current + 16 }
    capacity { 4 }
    seats_taken { 0 }
    status { :open }
  end
end
