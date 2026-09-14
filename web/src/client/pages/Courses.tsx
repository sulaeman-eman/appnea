import { useRouteState } from '../data'
import { useLocale } from '../locale'
import CourseCard from '../components/CourseCard'
import { Empty, ErrorState, Loading } from '../components/states'
import type { Course, Meta } from '~/shared/types'

export default function Courses() {
  const { data, error, loading } = useRouteState()
  const { t } = useLocale()
  const payload = data as { courses: Course[]; meta: Meta } | null

  return (
    <>
      <div className="page-head">
        <div className="wrap">
          <h1>{t('courses.title')}</h1>
          <p>{t('courses.lead')}</p>
        </div>
      </div>

      <section className="block">
        <div className="wrap">
          {error && <ErrorState message={error} />}
          {loading && !payload && <Loading what={t('courses.title').toLowerCase()} />}
          {payload && payload.courses.length === 0 && <Empty message={t('courses.empty')} />}
          {payload && payload.courses.length > 0 && (
            <div className="grid">
              {payload.courses.map((course) => <CourseCard key={course.id} course={course} />)}
            </div>
          )}
        </div>
      </section>
    </>
  )
}
