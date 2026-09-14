import { Routes, Route, Navigate, useLocation } from 'react-router'
import type { ReactElement } from 'react'
import Layout from './components/Layout'
import ErrorBoundary from './components/ErrorBoundary'
import { routes } from './routes'
import { useAuth } from './auth'

/**
 * Client-side counterpart to the server's redirect. SSR already sends an
 * anonymous visitor to /login, so this only matters for in-app navigation and
 * for a session that expired while the tab was open.
 */
function RequireAuth({ children }: { children: ReactElement }) {
  const { user } = useAuth()
  const location = useLocation()

  if (!user) {
    return <Navigate to={`/login?next=${encodeURIComponent(location.pathname)}`} replace />
  }

  return children
}

export default function App() {
  const location = useLocation()

  return (
    <Layout>
      {/* Scoped inside the layout so a crashing page keeps the header and the
          visitor can navigate out of it. */}
      <ErrorBoundary resetKey={location.pathname + location.search}>
        <Routes>
          {routes.map(({ path, Component, requiresAuth }) => (
            <Route
              key={path}
              path={path}
              element={requiresAuth ? <RequireAuth><Component /></RequireAuth> : <Component />}
            />
          ))}
        </Routes>
      </ErrorBoundary>
    </Layout>
  )
}
