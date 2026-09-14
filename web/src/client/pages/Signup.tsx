import { useState, type FormEvent } from 'react'
import { Link, useNavigate } from 'react-router'
import { useAuth } from '../auth'
import { useLocale } from '../locale'
import { ApiError } from '~/shared/api'

export default function Signup() {
  const { signup } = useAuth()
  const { t } = useLocale()
  const navigate = useNavigate()
  const [name, setName] = useState('')
  const [email, setEmail] = useState('')
  const [password, setPassword] = useState('')
  const [error, setError] = useState<string | null>(null)
  const [busy, setBusy] = useState(false)

  async function submit(event: FormEvent) {
    event.preventDefault()
    setBusy(true)
    setError(null)

    try {
      await signup({ name, email, password })
      navigate('/bookings', { replace: true })
    } catch (caught) {
      setError(
        caught instanceof ApiError && caught.status === 422
          ? t('auth.signupInvalid')
          : t('auth.signupFailed'),
      )
    } finally {
      setBusy(false)
    }
  }

  return (
    <div className="wrap form-page">
      <h1>{t('auth.createAccount')}</h1>
      <form onSubmit={submit} className="form">
        {error && <p className="form-error">{error}</p>}

        <label>
          {t('auth.name')}
          <input value={name} onChange={(e) => setName(e.target.value)} required autoComplete="name" />
        </label>

        <label>
          {t('auth.email')}
          <input type="email" value={email} onChange={(e) => setEmail(e.target.value)}
            required autoComplete="email" />
        </label>

        <label>
          {t('auth.password')}
          <input type="password" value={password} onChange={(e) => setPassword(e.target.value)}
            required minLength={8} autoComplete="new-password" />
          <small>{t('auth.passwordHint')}</small>
        </label>

        <button type="submit" className="button" disabled={busy}>
          {busy ? t('auth.creating') : t('auth.createAccount')}
        </button>
      </form>

      <p className="form-foot">
        {t('auth.haveAccount')} <Link to="/login">{t('auth.signIn')}</Link>
      </p>
    </div>
  )
}
