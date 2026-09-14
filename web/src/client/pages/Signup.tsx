import { useState, type FormEvent } from 'react'
import { Link, useNavigate } from 'react-router'
import { useAuth } from '../auth'
import { ApiError } from '~/shared/api'

export default function Signup() {
  const { signup } = useAuth()
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
          ? 'Check the form — that email may already be registered, or the password is under 8 characters.'
          : 'Could not create the account right now. Try again in a moment.',
      )
    } finally {
      setBusy(false)
    }
  }

  return (
    <div className="wrap form-page">
      <h1>Create an account</h1>
      <form onSubmit={submit} className="form">
        {error && <p className="form-error">{error}</p>}

        <label>
          Name
          <input value={name} onChange={(e) => setName(e.target.value)} required autoComplete="name" />
        </label>

        <label>
          Email
          <input type="email" value={email} onChange={(e) => setEmail(e.target.value)} required autoComplete="email" />
        </label>

        <label>
          Password
          <input
            type="password" value={password} onChange={(e) => setPassword(e.target.value)}
            required minLength={8} autoComplete="new-password"
          />
          <small>At least 8 characters.</small>
        </label>

        <button type="submit" className="button" disabled={busy}>
          {busy ? 'Creating…' : 'Create account'}
        </button>
      </form>

      <p className="form-foot">
        Already have an account? <Link to="/login">Sign in</Link>.
      </p>
    </div>
  )
}
