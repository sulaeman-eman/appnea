import { hydrateRoot } from 'react-dom/client'
import { BrowserRouter } from 'react-router'
import { StrictMode } from 'react'
import App from './App'
import { RouteDataProvider, type RouteState } from './data'
import { AuthProvider } from './auth'
import type { User } from '~/shared/types'
import './styles.css'

declare global {
  interface Window {
    __APPNEA__?: { url: string; data: unknown; error: string | null; user: User | null }
  }
}

const bootstrap = window.__APPNEA__
const initial: RouteState = {
  url: bootstrap?.url ?? window.location.pathname + window.location.search,
  data: bootstrap?.data ?? null,
  error: bootstrap?.error ?? null,
  loading: false,
}

hydrateRoot(
  document.getElementById('root')!,
  <StrictMode>
    <BrowserRouter>
      <AuthProvider initialUser={bootstrap?.user ?? null}>
        <RouteDataProvider initial={initial}>
          <App />
        </RouteDataProvider>
      </AuthProvider>
    </BrowserRouter>
  </StrictMode>,
)
