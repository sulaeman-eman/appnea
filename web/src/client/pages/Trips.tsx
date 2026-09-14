import { Link } from 'react-router'
import { useRouteState } from '../data'
import { Empty, ErrorState, Loading } from '../components/states'
import type { Meta, Trip } from '~/shared/types'
import { formatDateRange, formatPrice } from '~/shared/format'

export default function Trips() {
  const { data, error, loading } = useRouteState()
  const payload = data as { trips: Trip[]; meta: Meta } | null

  return (
    <>
      <div className="page-head">
        <div className="wrap">
          <h1>Trips</h1>
          <p>Guided fun dives and coached depth camps around Bali and Nusa Penida.</p>
        </div>
      </div>

      <section className="block">
        <div className="wrap">
          {error && <ErrorState message={error} />}
          {loading && !payload && <Loading what="trips" />}
          {payload && payload.trips.length === 0 && <Empty message="No trips on the calendar right now." />}
          {payload && payload.trips.length > 0 && (
            <div className="grid">
              {payload.trips.map((trip) => (
                <Link key={trip.id} to={`/trips/${trip.slug}`} className="card">
                  <span className="tag">{trip.destination}</span>
                  <h3>{trip.title}</h3>
                  <p>{trip.summary}</p>
                  <div className="card-meta">
                    <span>{formatDateRange(trip.startDate, trip.endDate)}</span>
                    <span className="price">{formatPrice(trip.priceCents, trip.currency)}</span>
                  </div>
                </Link>
              ))}
            </div>
          )}
        </div>
      </section>
    </>
  )
}
