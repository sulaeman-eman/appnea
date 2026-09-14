class ScheduleBlueprint < Blueprinter::Base
  identifier :id

  fields :start_date, :end_date, :capacity, :seats_taken, :status

  field :seats_available
  field :course_id

  association :instructor, blueprint: InstructorBlueprint, view: :summary

  # Used when the schedule is nested inside its own course, where repeating the
  # course would be circular.
  view :without_course do
    excludes :course_id
  end

  view :with_course do
    association :course, blueprint: CourseBlueprint
  end
end
