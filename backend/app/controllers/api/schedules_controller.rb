module Api
  class SchedulesController < BaseController
    def index
      scope = Schedule.bookable
        .joins(:course).merge(Course.published)
        .includes(:course, :instructor)

      scope = scope.where(course_id: params[:course_id]) if params[:course_id].present?
      scope = scope.where(start_date: Date.parse(params[:from])..) if params[:from].present?

      schedules = paginate(scope)

      render json: {
        schedules: ScheduleBlueprint.render_as_hash(schedules, view: :with_course),
        meta: meta_for(scope, schedules)
      }
    rescue Date::Error
      render json: { error: "invalid_date", detail: "from must be an ISO 8601 date" }, status: :bad_request
    end

    def show
      schedule = Schedule.joins(:course).merge(Course.published).find(params[:id])
      render json: { schedule: ScheduleBlueprint.render_as_hash(schedule, view: :with_course) }
    end
  end
end
