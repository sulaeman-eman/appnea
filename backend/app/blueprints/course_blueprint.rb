class CourseBlueprint < Blueprinter::Base
  identifier :id

  fields :slug, :agency, :depth_target_m, :duration_days, :price_cents, :currency

  # Translated fields read through the locale the request asked for and fall
  # back to the base column when there is no override.
  field :title do |course, options|
    course.translated(:title, options[:locale])
  end

  field :level do |course, options|
    course.translated(:level, options[:locale])
  end

  field :summary do |course, options|
    course.translated(:summary, options[:locale])
  end

  field :available_locales do |course|
    course.translated_locales
  end

  field :cover_image_url do |course|
    course.cover_image_url(:card)
  end

  # The index view stays light: no description, no schedules.
  view :detail do
    field :description do |course, options|
      course.translated(:description, options[:locale])
    end

    field :cover_image_url do |course|
      course.cover_image_url(:hero)
    end

    association :schedules, blueprint: ScheduleBlueprint, view: :without_course do |course|
      course.schedules.bookable
    end
  end
end
