import { Link } from 'react-router'

export default function NotFound() {
  return (
    <div className="state">
      <h1>404 — not found</h1>
      <p>That page does not exist.</p>
      <Link to="/" className="button">Back to the home page</Link>
    </div>
  )
}
