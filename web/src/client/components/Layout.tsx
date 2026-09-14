import { NavLink, Link, useNavigate } from 'react-router'
import type { ReactNode } from 'react'
import { useAuth } from '../auth'

const NAV = [
  { to: '/courses', label: 'Courses' },
  { to: '/trips', label: 'Trips' },
  { to: '/instructors', label: 'Instructors' },
  { to: '/blog', label: 'Blog' },
]

export default function Layout({ children }: { children: ReactNode }) {
  const { user, logout } = useAuth()
  const navigate = useNavigate()

  async function signOut() {
    await logout()
    navigate('/', { replace: true })
  }

  return (
    <>
      <header className="site-header">
        <div className="wrap">
          <Link to="/" className="brand">Appnea</Link>

          <nav className="site-nav">
            {NAV.map((item) => (
              <NavLink key={item.to} to={item.to} className={({ isActive }) => (isActive ? 'active' : undefined)}>
                {item.label}
              </NavLink>
            ))}

            {user ? (
              <>
                <NavLink to="/bookings" className={({ isActive }) => (isActive ? 'active' : undefined)}>
                  Bookings
                </NavLink>
                <button type="button" className="link-button on-dark" onClick={signOut}>
                  Sign out ({user.name.split(' ')[0]})
                </button>
              </>
            ) : (
              <NavLink to="/login" className={({ isActive }) => (isActive ? 'active' : undefined)}>
                Sign in
              </NavLink>
            )}
          </nav>
        </div>
      </header>

      <main>{children}</main>

      <footer className="site-footer">
        <div className="wrap">
          <span>Appnea — freediving in Bali</span>
          <span>Amed · Nusa Penida</span>
        </div>
      </footer>
    </>
  )
}
