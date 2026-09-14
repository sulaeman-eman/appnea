class InstructorBlueprint < Blueprinter::Base
  identifier :id

  fields :name, :certifications

  field :bio
  field :photo_url do |instructor|
    instructor.photo.attached? ? Rails.application.routes.url_helpers.rails_blob_path(instructor.photo, only_path: true) : nil
  end

  view :summary do
    excludes :bio
  end
end
