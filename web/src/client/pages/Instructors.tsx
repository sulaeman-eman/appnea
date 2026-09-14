import { useRouteState } from '../data'
import { Empty, ErrorState, Loading } from '../components/states'
import type { Instructor } from '~/shared/types'

export default function Instructors() {
  const { data, error, loading } = useRouteState()
  const payload = data as { instructors: Instructor[] } | null

  return (
    <>
      <div className="page-head">
        <div className="wrap">
          <h1>Instructors</h1>
          <p>The people who will be on the line with you.</p>
        </div>
      </div>

      <section className="block">
        <div className="wrap">
          {error && <ErrorState message={error} />}
          {loading && !payload && <Loading what="instructors" />}
          {payload && payload.instructors.length === 0 && <Empty message="No instructor profiles yet." />}
          {payload && (
            <div className="grid">
              {payload.instructors.map((instructor) => (
                <div key={instructor.id} className="card">
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
