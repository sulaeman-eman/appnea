import { useRouteState } from '../data'
import { useLocale } from '../locale'
import ScheduleList from '../components/ScheduleList'
import { ErrorState, Loading } from '../components/states'
import type { CourseDetail } from '~/shared/types'
import { AGENCY_LABEL, formatPrice } from '~/shared/format'

export default function CourseDetailPage() {
  const { data, error, loading } = useRouteState()
  const { t } = useLocale()
  const course = (data as { course: CourseDetail } | null)?.course

  if (error) return <ErrorState message={error} />
  if (loading || !course) return <Loading />

  return (
    <>
      {course.coverImageUrl && (
        <div className="hero-image">
          <img src={course.coverImageUrl} alt="" />
        </div>
      )}

      <div className="page-head">
        <div className="wrap">
          <span className="tag">
            {AGENCY_LABEL[course.agency] ?? course.agency} &middot; {course.level}
          </span>
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

          <h2>{t('courses.upcomingDates')}</h2>
          <ScheduleList schedules={course.schedules} />
        </div>

        <aside className="facts">
          <dl>
            <div>
              <dt>{t('courses.price')}</dt>
              <dd>{formatPrice(course.priceCents, course.currency)}</dd>
            </div>
            <div>
              <dt>{t('courses.duration')}</dt>
              <dd>{course.durationDays} {t('courses.days')}</dd>
            </div>
            {course.depthTargetM !== null && (
              <div>
                <dt>{t('courses.depthTarget')}</dt>
                <dd>{course.depthTargetM} m</dd>
              </div>
            )}
            <div>
              <dt>{t('courses.agency')}</dt>
              <dd>{AGENCY_LABEL[course.agency] ?? course.agency}</dd>
            </div>
          </dl>
        </aside>
      </div>
    </>
  )
}
