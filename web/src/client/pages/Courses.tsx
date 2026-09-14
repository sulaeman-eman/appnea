import { useRouteState } from '../data'
import CourseCard from '../components/CourseCard'
import { Empty, ErrorState, Loading } from '../components/states'
import type { Course, Meta } from '~/shared/types'

export default function Courses() {
  const { data, error, loading } = useRouteState()
  const payload = data as { courses: Course[]; meta: Meta } | null

  return (
    <>
      <div className="page-head">
        <div className="wrap">
          <h1>Courses</h1>
          <p>Every certification we teach, from your first breath-hold to 40 m and rescue competency.</p>
        </div>
      </div>

      <section className="block">
        <div className="wrap">
          {error && <ErrorState message={error} />}
          {loading && !payload && <Loading what="courses" />}
          {payload && payload.courses.length === 0 && <Empty message="No courses published yet." />}
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
