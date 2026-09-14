import { Link } from 'react-router'
import type { Schedule } from '~/shared/types'
import { formatDateRange } from '~/shared/format'

function seatsClass(available: number): string {
  if (available <= 0) return 'seats none'
  if (available <= 1) return 'seats low'
  return 'seats'
}

export default function ScheduleList({ schedules }: { schedules: Schedule[] }) {
  if (schedules.length === 0) {
    return <p className="state">No dates scheduled yet. Get in touch and we will arrange one.</p>
  }

  return (
    <div className="schedule-list">
      {schedules.map((schedule) => (
        <div key={schedule.id} className="schedule-row">
          <div>
            <div className="when">{formatDateRange(schedule.startDate, schedule.endDate)}</div>
            <div className="who">
              {schedule.instructor ? `with ${schedule.instructor.name}` : 'Instructor to be assigned'}
            </div>
          </div>

          <div className="schedule-actions">
            <span className={seatsClass(schedule.seatsAvailable)}>
              {schedule.seatsAvailable > 0
                ? `${schedule.seatsAvailable} of ${schedule.capacity} seats left`
                : 'Fully booked'}
            </span>
            {schedule.seatsAvailable > 0 && (
              <Link to={`/book/${schedule.id}`} className="button small">Book</Link>
            )}
          </div>
        </div>
      ))}
    </div>
  )
}
