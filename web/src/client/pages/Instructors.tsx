import { useRouteState } from '../data'
import { useLocale } from '../locale'
import { Empty, ErrorState, Loading } from '../components/states'
import type { Instructor } from '~/shared/types'

export default function Instructors() {
  const { data, error, loading } = useRouteState()
  const { t } = useLocale()
  const payload = data as { instructors: Instructor[] } | null

  return (
    <>
      <div className="page-head">
        <div className="wrap">
          <h1>{t('instructors.title')}</h1>
          <p>{t('instructors.lead')}</p>
        </div>
      </div>

      <section className="block">
        <div className="wrap">
          {error && <ErrorState message={error} />}
          {loading && !payload && <Loading what={t('instructors.title').toLowerCase()} />}
          {payload && payload.instructors.length === 0 && <Empty message={t('instructors.empty')} />}
          {payload && (
            <div className="grid">
              {payload.instructors.map((instructor) => (
                <div key={instructor.id} className="card">
                  {instructor.photoUrl && (
                    <img className="card-image portrait" src={instructor.photoUrl}
                      alt={instructor.name} loading="lazy" />
                  )}
                  <h3>{instructor.name}</h3>
                  <p>{instructor.bio}</p>
                  <div className="card-meta">
                    {instructor.certifications.map((cert) => <span key={cert}>{cert}</span>)}
                  </div>
                </div>
              ))}
            </div>
          )}
        </div>
      </section>
    </>
  )
}
