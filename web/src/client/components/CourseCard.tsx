import { Link } from 'react-router'
import type { Course } from '~/shared/types'
import { AGENCY_LABEL, formatPrice } from '~/shared/format'

export default function CourseCard({ course }: { course: Course }) {
  return (
    <Link to={`/courses/${course.slug}`} className="card">
      <span className="tag">{AGENCY_LABEL[course.agency] ?? course.agency} · {course.level}</span>
      <h3>{course.title}</h3>
      <p>{course.summary}</p>
      <div className="card-meta">
        <span>{course.durationDays} days</span>
        {course.depthTargetM !== null && <span>to {course.depthTargetM} m</span>}
        <span className="price">{formatPrice(course.priceCents, course.currency)}</span>
      </div>
    </Link>
  )
}
