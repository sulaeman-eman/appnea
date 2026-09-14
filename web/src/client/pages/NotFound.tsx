import { Link } from 'react-router'
import { useLocale } from '../locale'

export default function NotFound() {
  const { t } = useLocale()

  return (
    <div className="state">
      <h1>404 {t('notFound.title')}</h1>
      <p>{t('notFound.body')}</p>
      <Link to="/" className="button">{t('notFound.home')}</Link>
    </div>
  )
}
