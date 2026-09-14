import { Link } from 'react-router'
import { useRouteState } from '../data'
import { useLocale } from '../locale'
import { Empty, ErrorState, Loading } from '../components/states'
import type { Meta, Trip } from '~/shared/types'
import { formatDateRange, formatPrice } from '~/shared/format'

export default function Trips() {
  const { data, error, loading } = useRouteState()
  const { t } = useLocale()
  const payload = data as { trips: Trip[]; meta: Meta } | null

  return (
    <>
      <div className="page-head">
        <div className="wrap">
          <h1>{t('trips.title')}</h1>
          <p>{t('trips.lead')}</p>
        </div>
      </div>

      <section className="block">
        <div className="wrap">
          {error && <ErrorState message={error} />}
          {loading && !payload && <Loading what={t('trips.title').toLowerCase()} />}
          {payload && payload.trips.length === 0 && <Empty message={t('trips.empty')} />}
          {payload && payload.trips.length > 0 && (
            <div className="grid">
              {payload.trips.map((trip) => (
                <Link key={trip.id} to={`/trips/${trip.slug}`} className="card">
                  {trip.coverImageUrl && (
                    <img className="card-image" src={trip.coverImageUrl} alt="" loading="lazy" />
                  )}
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
