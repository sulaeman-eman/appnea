module Api
  class CoursesController < BaseController
    def index
      scope = Course.published
      scope = params[:q].present? ? scope.search(params[:q]) : scope.order(:duration_days, :title)
      courses = paginate(scope)

      render json: {
        courses: CourseBlueprint.render_as_hash(courses, locale: current_locale),
        meta: meta_for(scope, courses)
      }
    end

    def show
      course = Course.published.find_by!(slug: params[:slug])

      render json: {
        course: CourseBlueprint.render_as_hash(course, view: :detail, locale: current_locale)
      }
    end
  end
end
