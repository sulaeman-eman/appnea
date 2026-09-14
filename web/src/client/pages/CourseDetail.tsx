import { useRouteState } from '../data'
import ScheduleList from '../components/ScheduleList'
import { ErrorState, Loading } from '../components/states'
import type { CourseDetail } from '~/shared/types'
import { AGENCY_LABEL, formatPrice } from '~/shared/format'

export default function CourseDetailPage() {
  const { data, error, loading } = useRouteState()
  const course = (data as { course: CourseDetail } | null)?.course

  if (error) return <ErrorState message={error} />
  if (loading || !course) return <Loading what="course" />

  return (
    <>
      <div className="page-head">
        <div className="wrap">
          <span className="tag">{AGENCY_LABEL[course.agency] ?? course.agency} · {course.level}</span>
          <h1>{course.title}</h1>
          <p>{course.summary}</p>
        </div>
      </div>

      <div className="wrap detail-layout">
        <div>
          <div className="prose">
            {course.description.split('\n').filter(Boolean).map((paragraph, index) => (
              <p key={index}>{paragraph}</p>
            ))}
          </div>

          <h2>Upcoming dates</h2>
          <ScheduleList schedules={course.schedules} />
        </div>

        <aside className="facts">
          <dl>
            <div>
              <dt>Price</dt>
              <dd>{formatPrice(course.priceCents, course.currency)}</dd>
            </div>
            <div>
              <dt>Duration</dt>
              <dd>{course.durationDays} days</dd>
            </div>
            {course.depthTargetM !== null && (
              <div>
                <dt>Depth target</dt>
                <dd>{course.depthTargetM} m</dd>
              </div>
            )}
            <div>
              <dt>Agency</dt>
              <dd>{AGENCY_LABEL[course.agency] ?? course.agency}</dd>
            </div>
          </dl>
        </aside>
      </div>
    </>
  )
}
