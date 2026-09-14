module Api
  class CoursesController < BaseController
    def index
      scope = Course.published.order(:duration_days, :title)
      courses = paginate(scope)

      render json: {
        courses: CourseBlueprint.render_as_hash(courses),
        meta: meta_for(scope, courses)
      }
    end

    def show
      course = Course.published.find_by!(slug: params[:slug])

      render json: {
        course: CourseBlueprint.render_as_hash(course, view: :detail)
      }
    end
  end
end
