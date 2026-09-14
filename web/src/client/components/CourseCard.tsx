import { Link } from 'react-router'
import type { Course } from '~/shared/types'
import { AGENCY_LABEL, formatPrice } from '~/shared/format'
import { useLocale } from '../locale'

export default function CourseCard({ course }: { course: Course }) {
  const { t } = useLocale()

  return (
    <Link to={`/courses/${course.slug}`} className="card">
      {course.coverImageUrl && (
        // Decorative: the title right below carries the meaning, so an alt
        // repeating it would just be read out twice.
        <img className="card-image" src={course.coverImageUrl} alt="" loading="lazy" />
      )}

      <span className="tag">
        {AGENCY_LABEL[course.agency] ?? course.agency} &middot; {course.level}
      </span>
      <h3>{course.title}</h3>
      <p>{course.summary}</p>

      <div className="card-meta">
        <span>{course.durationDays} {t('courses.days')}</span>
        {course.depthTargetM !== null && <span>{t('courses.to')} {course.depthTargetM} m</span>}
        <span className="price">{formatPrice(course.priceCents, course.currency)}</span>
      </div>
    </Link>
  )
}
