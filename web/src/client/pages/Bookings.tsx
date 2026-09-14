import { useState } from 'react'
import { Link } from 'react-router'
import { useRouteState } from '../data'
import { Empty, ErrorState, Loading } from '../components/states'
import { api } from '~/shared/api'
import type { Booking } from '~/shared/types'
import { formatDateRange, formatPrice } from '~/shared/format'

const STATUS_LABEL: Record<string, string> = {
  pending: 'Awaiting confirmation',
  confirmed: 'Confirmed',
  cancelled: 'Cancelled',
}

export default function Bookings() {
  const { data, error, loading } = useRouteState()
  const [bookings, setBookings] = useState<Booking[] | null>(null)
  const [busyId, setBusyId] = useState<number | null>(null)
  const [actionError, setActionError] = useState<string | null>(null)

  const payload = data as { bookings: Booking[] } | null
  const list = bookings ?? payload?.bookings ?? null

  async function cancel(id: number) {
    setBusyId(id)
    setActionError(null)

    try {
      const { booking } = await api.cancelBooking(id)
      setBookings((list ?? []).map((item) => (item.id === id ? booking : item)))
    } catch {
      setActionError('Could not cancel that booking. Refresh and try again.')
    } finally {
      setBusyId(null)
    }
  }

  return (
    <>
      <div className="page-head">
        <div className="wrap">
          <h1>Your bookings</h1>
          <p>Seats are held as soon as you book. An instructor confirms the dates by email.</p>
        </div>
      </div>

      <section className="block">
        <div className="wrap">
          {error && <ErrorState message={error} />}
          {loading && !list && <Loading what="bookings" />}
          {actionError && <p className="form-error">{actionError}</p>}

          {list && list.length === 0 && (
            <Empty message="No bookings yet." />
          )}

          {list && list.length > 0 && (
            <div className="schedule-list">
              {list.map((booking) => (
                <div key={booking.id} className="schedule-row">
                  <div>
                    <div className="when">
                      <Link to={`/courses/${booking.schedule.course.slug}`}>{booking.schedule.course.title}</Link>
                    </div>
                    <div className="who">
                      {formatDateRange(booking.schedule.startDate, booking.schedule.endDate)}
                      {' · '}
                      {booking.participants} {booking.participants === 1 ? 'person' : 'people'}
                      {' · '}
                      {formatPrice(booking.totalCents, booking.schedule.course.currency)}
                    </div>
                  </div>

                  <div>
                    <span className={`seats ${booking.status === 'cancelled' ? 'none' : ''}`}>
                      {STATUS_LABEL[booking.status] ?? booking.status}
                    </span>
                    {booking.status !== 'cancelled' && (
                      <>
                        {' '}
                        <button
                          type="button" className="link-button"
                          onClick={() => cancel(booking.id)} disabled={busyId === booking.id}
                        >
                          {busyId === booking.id ? 'Cancelling…' : 'Cancel'}
                        </button>
                      </>
                    )}
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
