import { useState } from 'react'
import { Link } from 'react-router'
import { useRouteState } from '../data'
import { useLocale } from '../locale'
import { Empty, ErrorState, Loading } from '../components/states'
import { api } from '~/shared/api'
import type { Booking } from '~/shared/types'
import type { TranslationKey } from '~/shared/i18n'
import { formatDateRange, formatPrice } from '~/shared/format'

const STATUS_KEY: Record<string, TranslationKey> = {
  pending: 'bookings.pending',
  confirmed: 'bookings.confirmed',
  cancelled: 'bookings.cancelled',
}

export default function Bookings() {
  const { data, error, loading } = useRouteState()
  const { t } = useLocale()
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
      setActionError(t('bookings.cancelFailed'))
    } finally {
      setBusyId(null)
    }
  }

  return (
    <>
      <div className="page-head">
        <div className="wrap">
          <h1>{t('bookings.title')}</h1>
          <p>{t('bookings.lead')}</p>
        </div>
      </div>

      <section className="block">
        <div className="wrap">
          {error && <ErrorState message={error} />}
          {loading && !list && <Loading what={t('nav.bookings').toLowerCase()} />}
          {actionError && <p className="form-error">{actionError}</p>}

          {list && list.length === 0 && <Empty message={t('bookings.empty')} />}

          {list && list.length > 0 && (
            <div className="schedule-list">
              {list.map((booking) => (
                <div key={booking.id} className="schedule-row">
                  <div>
                    <div className="when">
                      <Link to={`/courses/${booking.schedule.course.slug}`}>
                        {booking.schedule.course.title}
                      </Link>
                    </div>
                    <div className="who">
                      {formatDateRange(booking.schedule.startDate, booking.schedule.endDate)}
                      {' - '}
                      {booking.participants}{' '}
                      {booking.participants === 1 ? t('bookings.person') : t('bookings.people')}
                      {' - '}
                      {formatPrice(booking.totalCents, booking.schedule.course.currency)}
                    </div>
                  </div>

                  <div>
                    <span className={`seats ${booking.status === 'cancelled' ? 'none' : ''}`}>
                      {t(STATUS_KEY[booking.status] ?? 'bookings.pending')}
                    </span>
                    {booking.status !== 'cancelled' && (
                      <>
                        {' '}
                        <button type="button" className="link-button"
                          onClick={() => cancel(booking.id)} disabled={busyId === booking.id}>
                          {busyId === booking.id ? t('bookings.cancelling') : t('bookings.cancel')}
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
