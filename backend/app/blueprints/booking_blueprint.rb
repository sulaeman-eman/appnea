class BookingBlueprint < Blueprinter::Base
  identifier :id

  fields :participants, :status, :total_cents, :notes, :created_at

  association :schedule, blueprint: ScheduleBlueprint, view: :with_course
end
