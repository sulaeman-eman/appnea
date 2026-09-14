import { useRouteState } from '../data'
import { ErrorState, Loading } from '../components/states'
import type { TripDetail } from '~/shared/types'
import { formatDateRange, formatPrice } from '~/shared/format'

export default function TripDetailPage() {
  const { data, error, loading } = useRouteState()
  const trip = (data as { trip: TripDetail } | null)?.trip

  if (error) return <ErrorState message={error} />
  if (loading || !trip) return <Loading what="trip" />

  return (
    <>
      <div className="page-head">
        <div className="wrap">
          <span className="tag">{trip.destination}</span>
          <h1>{trip.title}</h1>
          <p>{trip.summary}</p>
        </div>
      </div>

      <div className="wrap detail-layout">
        <div className="prose">
          {trip.description.split('\n').filter(Boolean).map((paragraph, index) => (
            <p key={index}>{paragraph}</p>
          ))}
        </div>

        <aside className="facts">
          <dl>
            <div>
              <dt>Dates</dt>
              <dd>{formatDateRange(trip.startDate, trip.endDate)}</dd>
            </div>
            <div>
              <dt>Price</dt>
              <dd>{formatPrice(trip.priceCents, trip.currency)}</dd>
            </div>
            <div>
              <dt>Group size</dt>
              <dd>Up to {trip.capacity}</dd>
            </div>
          </dl>
        </aside>
      </div>
    </>
  )
}
