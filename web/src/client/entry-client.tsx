import { hydrateRoot } from 'react-dom/client'
import { BrowserRouter } from 'react-router'
import { StrictMode } from 'react'
import App from './App'
import { RouteDataProvider, type RouteState } from './data'
import { AuthProvider } from './auth'
import { LocaleProvider } from './locale'
import { routeKey } from './routes'
import { DEFAULT_LOCALE, isLocale, type Locale } from '~/shared/i18n'
import type { User } from '~/shared/types'
import './styles.css'

declare global {
  interface Window {
    __APPNEA__?: {
      key: string
      data: unknown
      error: string | null
      user: User | null
      locale: Locale
    }
  }
}

const bootstrap = window.__APPNEA__
const locale: Locale = isLocale(bootstrap?.locale) ? bootstrap.locale : DEFAULT_LOCALE

const initial: RouteState = {
  key: bootstrap?.key ?? routeKey(window.location.pathname + window.location.search, locale),
  data: bootstrap?.data ?? null,
  error: bootstrap?.error ?? null,
  loading: false,
}

hydrateRoot(
  document.getElementById('root')!,
  <StrictMode>
    <BrowserRouter>
      <LocaleProvider initial={locale}>
        <AuthProvider initialUser={bootstrap?.user ?? null}>
          <RouteDataProvider initial={initial}>
            <App />
          </RouteDataProvider>
        </AuthProvider>
      </LocaleProvider>
    </BrowserRouter>
  </StrictMode>,
)
