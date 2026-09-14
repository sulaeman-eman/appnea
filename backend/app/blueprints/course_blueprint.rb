class CourseBlueprint < Blueprinter::Base
  identifier :id

  fields :slug, :title, :agency, :level, :depth_target_m, :duration_days,
    :price_cents, :currency, :summary

  field :cover_image_url do |course|
    course.cover_image.attached? ? Rails.application.routes.url_helpers.rails_blob_path(course.cover_image, only_path: true) : nil
  end

  # The index view stays light: no description, no schedules.
  view :detail do
    field :description

    association :schedules, blueprint: ScheduleBlueprint, view: :without_course do |course|
      course.schedules.bookable
    end
  end
end
