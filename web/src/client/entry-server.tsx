import { renderToString } from 'react-dom/server'
import { StaticRouter } from 'react-router'
import App from './App'
import { RouteDataProvider, type RouteState } from './data'
import { AuthProvider } from './auth'
import { LocaleProvider } from './locale'
import { findRoute, routeKey } from './routes'
import { api, ApiError, type RequestContext } from '~/shared/api'
import { DEFAULT_LOCALE, type Locale } from '~/shared/i18n'
import type { User } from '~/shared/types'

export interface RenderOptions {
  token?: string | null
  locale?: Locale
}

export interface RenderResult {
  html: string
  head: string
  lang: Locale
  status: number
  redirect?: string
  bootstrap: { key: string; data: unknown; error: string | null; user: User | null; locale: Locale }
}

function escapeHtml(value: string): string {
  return value
    .replace(/&/g, '&amp;')
    .replace(/</g, '&lt;')
    .replace(/>/g, '&gt;')
    .replace(/"/g, '&quot;')
}

export async function render(url: string, options: RenderOptions = {}): Promise<RenderResult> {
  const [pathname = '/', search = ''] = url.split('?')
  const locale = options.locale ?? DEFAULT_LOCALE
  const match = findRoute(pathname)
  const ctx: RequestContext = { token: options.token, locale }

  // Resolve the visitor first: the header needs it on every page, and the auth
  // guard below needs it before deciding whether to render at all.
  let user: User | null = null
  if (options.token) {
    try {
      user = (await api.me(ctx)).user
    } catch {
      // An expired or revoked token is simply an anonymous visitor.
      user = null
    }
  }

  if (match?.route.requiresAuth && !user) {
    return {
      html: '',
      head: '',
      lang: locale,
      status: 302,
      redirect: `/login?next=${encodeURIComponent(url)}`,
      bootstrap: { key: routeKey(url, locale), data: null, error: null, user: null, locale },
    }
  }

  let data: unknown = null
  let error: string | null = null
  let status = match?.route.path === '*' ? 404 : 200

  if (match?.route.loader) {
    try {
      data = await match.route.loader({
        params: match.params,
        query: new URLSearchParams(search),
        ctx,
      })
    } catch (caught) {
      // A 404 from the API is a real 404 for this URL, not a server fault:
      // crawlers need the status code to match what the page actually says.
      if (caught instanceof ApiError) {
        status = caught.status === 404 ? 404 : 502
        error = caught.status === 404 ? 'That page could not be found.' : 'The API is not responding right now.'
      } else {
        status = 500
        error = caught instanceof Error ? caught.message : 'Something went wrong.'
      }
    }
  }

  const meta = match?.route.meta(data, locale) ?? { title: 'Appnea', description: '' }
  const initial: RouteState = { key: routeKey(url, locale), data, error, loading: false }

  const html = renderToString(
    <StaticRouter location={url}>
      <LocaleProvider initial={locale}>
        <AuthProvider initialUser={user}>
          <RouteDataProvider initial={initial}>
            <App />
          </RouteDataProvider>
        </AuthProvider>
      </LocaleProvider>
    </StaticRouter>,
  )

  const head = [
    `<title>${escapeHtml(meta.title)}</title>`,
    `<meta name="description" content="${escapeHtml(meta.description)}" />`,
    `<meta property="og:title" content="${escapeHtml(meta.title)}" />`,
    `<meta property="og:description" content="${escapeHtml(meta.description)}" />`,
    `<meta property="og:type" content="website" />`,
    `<meta property="og:locale" content="${locale === 'id' ? 'id_ID' : 'en_US'}" />`,
    `<meta name="twitter:card" content="summary_large_image" />`,
    // Signed-in pages are per-visitor; a shared cache must never serve one to
    // someone else.
    user ? `<meta name="robots" content="noindex" />` : '',
  ].filter(Boolean).join('\n    ')

  return {
    html,
    head,
    lang: locale,
    status,
    bootstrap: { key: initial.key, data, error, user, locale },
  }
}
