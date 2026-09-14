import { useState, type FormEvent } from 'react'
import { Link, useNavigate, useLocation } from 'react-router'
import { useAuth } from '../auth'
import { ApiError } from '~/shared/api'

export default function Login() {
  const { login } = useAuth()
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
          ? 'Those details did not match an account.'
          : 'Could not sign in right now. Try again in a moment.',
      )
    } finally {
      setBusy(false)
    }
  }

  return (
    <div className="wrap form-page">
      <h1>Sign in</h1>
      <form onSubmit={submit} className="form">
        {error && <p className="form-error">{error}</p>}

        <label>
          Email
          <input type="email" value={email} onChange={(e) => setEmail(e.target.value)} required autoComplete="email" />
        </label>

        <label>
          Password
          <input
            type="password" value={password} onChange={(e) => setPassword(e.target.value)}
            required autoComplete="current-password"
          />
        </label>

        <button type="submit" className="button" disabled={busy}>
          {busy ? 'Signing in…' : 'Sign in'}
        </button>
      </form>

      <p className="form-foot">
        No account yet? <Link to="/signup">Create one</Link>.
      </p>
    </div>
  )
}
