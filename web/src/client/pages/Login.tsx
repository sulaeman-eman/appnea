import { useState, type FormEvent } from 'react'
import { Link, useNavigate, useLocation } from 'react-router'
import { useAuth } from '../auth'
import { useLocale } from '../locale'
import { ApiError } from '~/shared/api'

export default function Login() {
  const { login } = useAuth()
  const { t } = useLocale()
  const navigate = useNavigate()
  const location = useLocation()
  const [email, setEmail] = useState('')
  const [password, setPassword] = useState('')
  const [error, setError] = useState<string | null>(null)
  const [busy, setBusy] = useState(false)

  const next = new URLSearchParams(location.search).get('next') ?? '/bookings'

  async function submit(event: FormEvent) {
    event.preventDefault()
    setBusy(true)
    setError(null)

    try {
      await login(email, password)
      navigate(next, { replace: true })
    } catch (caught) {
      setError(
        caught instanceof ApiError && caught.status === 401
          ? t('auth.badCredentials')
          : t('auth.signInFailed'),
      )
    } finally {
      setBusy(false)
    }
  }

  return (
    <div className="wrap form-page">
      <h1>{t('auth.signIn')}</h1>
      <form onSubmit={submit} className="form">
        {error && <p className="form-error">{error}</p>}

        <label>
          {t('auth.email')}
          <input type="email" value={email} onChange={(e) => setEmail(e.target.value)}
            required autoComplete="email" />
        </label>

        <label>
          {t('auth.password')}
          <input type="password" value={password} onChange={(e) => setPassword(e.target.value)}
            required autoComplete="current-password" />
        </label>

        <button type="submit" className="button" disabled={busy}>
          {busy ? t('auth.signingIn') : t('auth.signIn')}
        </button>
      </form>

      <p className="form-foot">
        {t('auth.noAccount')} <Link to="/signup">{t('auth.createOne')}</Link>
      </p>
    </div>
  )
}
