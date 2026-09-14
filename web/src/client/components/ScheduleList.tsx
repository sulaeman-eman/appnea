import { Link } from 'react-router'
import type { Schedule } from '~/shared/types'
import { formatDateRange } from '~/shared/format'
import { useLocale } from '../locale'

function seatsClass(available: number): string {
  if (available <= 0) return 'seats none'
  if (available <= 1) return 'seats low'
  return 'seats'
}

export default function ScheduleList({ schedules }: { schedules: Schedule[] }) {
  const { t } = useLocale()

  if (schedules.length === 0) {
    return <p className="state">{t('schedule.none')}</p>
  }

  return (
    <div className="schedule-list">
      {schedules.map((schedule) => (
        <div key={schedule.id} className="schedule-row">
          <div>
            <div className="when">{formatDateRange(schedule.startDate, schedule.endDate)}</div>
            <div className="who">
              {schedule.instructor
                ? `${t('schedule.with')} ${schedule.instructor.name}`
                : t('schedule.tbd')}
            </div>
          </div>

          <div className="schedule-actions">
            <span className={seatsClass(schedule.seatsAvailable)}>
              {schedule.seatsAvailable > 0
                ? `${schedule.seatsAvailable} ${t('schedule.of')} ${schedule.capacity} ${t('schedule.seatsLeft')}`
                : t('schedule.soldOut')}
            </span>
            {schedule.seatsAvailable > 0 && (
              <Link to={`/book/${schedule.id}`} className="button small">{t('schedule.book')}</Link>
            )}
          </div>
        </div>
      ))}
    </div>
  )
}
