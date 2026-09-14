module Api
  class InstructorsController < BaseController
    def index
      instructors = Instructor.ordered
      render json: { instructors: InstructorBlueprint.render_as_hash(instructors) }
    end
  end
end
