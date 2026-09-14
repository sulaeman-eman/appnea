import { useState, type FormEvent } from 'react'
import { useNavigate } from 'react-router'
import { useRouteState } from '../data'
import { useLocale } from '../locale'
import { ErrorState, Loading } from '../components/states'
import { api, ApiError } from '~/shared/api'
import type { ScheduleWithCourse } from '~/shared/types'
import { formatDateRange, formatPrice } from '~/shared/format'

export default function BookSchedule() {
  const { data, error, loading } = useRouteState()
  const { t } = useLocale()
  const schedule = (data as { schedule: ScheduleWithCourse } | null)?.schedule
  const navigate = useNavigate()

  const [participants, setParticipants] = useState(1)
  const [notes, setNotes] = useState('')
  const [formError, setFormError] = useState<string | null>(null)
  const [busy, setBusy] = useState(false)

  if (error) return <ErrorState message={error} />
  if (loading || !schedule) return <Loading />

  const soldOut = schedule.seatsAvailable <= 0

  async function submit(event: FormEvent) {
    event.preventDefault()
    if (!schedule) return

    setBusy(true)
    setFormError(null)

    try {
      await api.createBooking({ scheduleId: schedule.id, participants, notes })
      navigate('/bookings', { replace: true })
    } catch (caught) {
      if (caught instanceof ApiError && caught.status === 401) {
        navigate(`/login?next=/book/${schedule.id}`, { replace: true })
        return
      }
      // The seat count can change between page load and submit, so the server's
      // reason is more accurate than anything we could infer here.
      setFormError(
        caught instanceof ApiError ? (caught.detail ?? t('state.generic')) : t('state.generic'),
      )
    } finally {
      setBusy(false)
    }
  }

  return (
    <div className="wrap form-page">
      <h1>{t('booking.title')} {schedule.course.title}</h1>

      <div className="facts" style={{ marginBottom: 24 }}>
        <dl>
          <div>
            <dt>{t('trips.dates')}</dt>
            <dd>{formatDateRange(schedule.startDate, schedule.endDate)}</dd>
          </div>
          <div>
            <dt>{t('booking.instructor')}</dt>
            <dd>{schedule.instructor?.name ?? t('schedule.tbd')}</dd>
          </div>
          <div>
            <dt>{t('booking.seatsLeft')}</dt>
            <dd>{schedule.seatsAvailable} {t('schedule.of')} {schedule.capacity}</dd>
          </div>
          <div>
            <dt>{t('booking.perPerson')}</dt>
            <dd>{formatPrice(schedule.course.priceCents, schedule.course.currency)}</dd>
          </div>
        </dl>
      </div>

      {soldOut ? (
        <p className="form-error">{t('booking.soldOut')}</p>
      ) : (
        <form onSubmit={submit} className="form">
          {formError && <p className="form-error">{formError}</p>}

          <label>
            {t('booking.participants')}
            <input type="number" min={1} max={schedule.seatsAvailable} value={participants}
              onChange={(e) => setParticipants(Number(e.target.value))} required />
          </label>

          <label>
            {t('booking.notes')}
            <textarea value={notes} onChange={(e) => setNotes(e.target.value)} rows={4} />
            <small>{t('booking.notesHint')}</small>
          </label>

          <p className="total">
            {t('booking.total')}: {formatPrice(schedule.course.priceCents * participants, schedule.course.currency)}
          </p>

          <button type="submit" className="button" disabled={busy}>
            {busy ? t('booking.submitting') : t('booking.submit')}
          </button>
          <small>{t('booking.hold')}</small>
        </form>
      )}
    </div>
  )
}
