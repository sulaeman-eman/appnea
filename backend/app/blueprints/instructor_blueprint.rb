class InstructorBlueprint < Blueprinter::Base
  identifier :id

  fields :name, :certifications

  field :bio
  field :photo_url do |instructor|
    instructor.photo_url
  end

  view :summary do
    excludes :bio
  end
end
