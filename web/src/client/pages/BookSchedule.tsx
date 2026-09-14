import { useState, type FormEvent } from 'react'
import { useNavigate } from 'react-router'
import { useRouteState } from '../data'
import { ErrorState, Loading } from '../components/states'
import { api, ApiError } from '~/shared/api'
import type { ScheduleWithCourse } from '~/shared/types'
import { formatDateRange, formatPrice } from '~/shared/format'

export default function BookSchedule() {
  const { data, error, loading } = useRouteState()
  const schedule = (data as { schedule: ScheduleWithCourse } | null)?.schedule
  const navigate = useNavigate()

  const [participants, setParticipants] = useState(1)
  const [notes, setNotes] = useState('')
  const [formError, setFormError] = useState<string | null>(null)
  const [busy, setBusy] = useState(false)

  if (error) return <ErrorState message={error} />
  if (loading || !schedule) return <Loading what="schedule" />

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
        caught instanceof ApiError
          ? (caught.detail ?? 'That booking could not be completed.')
          : 'Something went wrong. Try again in a moment.',
      )
    } finally {
      setBusy(false)
    }
  }

  return (
    <div className="wrap form-page">
      <h1>Book {schedule.course.title}</h1>

      <div className="facts" style={{ marginBottom: 24 }}>
        <dl>
          <div>
            <dt>Dates</dt>
            <dd>{formatDateRange(schedule.startDate, schedule.endDate)}</dd>
          </div>
          <div>
            <dt>Instructor</dt>
            <dd>{schedule.instructor?.name ?? 'To be assigned'}</dd>
          </div>
          <div>
            <dt>Seats left</dt>
            <dd>{schedule.seatsAvailable} of {schedule.capacity}</dd>
          </div>
          <div>
            <dt>Price per person</dt>
            <dd>{formatPrice(schedule.course.priceCents, schedule.course.currency)}</dd>
          </div>
        </dl>
      </div>

      {soldOut ? (
        <p className="form-error">This date is fully booked. Pick another from the course page.</p>
      ) : (
        <form onSubmit={submit} className="form">
          {formError && <p className="form-error">{formError}</p>}

          <label>
            Participants
            <input
              type="number" min={1} max={schedule.seatsAvailable} value={participants}
              onChange={(e) => setParticipants(Number(e.target.value))} required
            />
          </label>

          <label>
            Anything we should know?
            <textarea value={notes} onChange={(e) => setNotes(e.target.value)} rows={4} />
            <small>Experience level, medical notes, who you are diving with.</small>
          </label>

          <p className="total">
            Total: {formatPrice(schedule.course.priceCents * participants, schedule.course.currency)}
          </p>

          <button type="submit" className="button" disabled={busy}>
            {busy ? 'Requesting…' : 'Request booking'}
          </button>
          <small>Your seats are held right away. Nothing is charged until an instructor confirms.</small>
        </form>
      )}
    </div>
  )
}
