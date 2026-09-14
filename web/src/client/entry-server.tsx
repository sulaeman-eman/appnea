import { renderToString } from 'react-dom/server'
import { StaticRouter } from 'react-router'
import App from './App'
import { RouteDataProvider, type RouteState } from './data'
import { AuthProvider } from './auth'
import { findRoute } from './routes'
import { api, ApiError, type RequestContext } from '~/shared/api'
import type { User } from '~/shared/types'

export interface RenderResult {
  html: string
  head: string
  status: number
  redirect?: string
  bootstrap: { url: string; data: unknown; error: string | null; user: User | null }
}

function escapeHtml(value: string): string {
  return value
    .replace(/&/g, '&amp;')
    .replace(/</g, '&lt;')
    .replace(/>/g, '&gt;')
    .replace(/"/g, '&quot;')
}

export async function render(url: string, token?: string | null): Promise<RenderResult> {
  const pathname = url.split('?')[0] ?? '/'
  const match = findRoute(pathname)
  const ctx: RequestContext = { token }

  // Resolve the visitor first: the header needs it on every page, and the auth
  // guard below needs it before deciding whether to render at all.
  let user: User | null = null
  if (token) {
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
      status: 302,
      redirect: `/login?next=${encodeURIComponent(url)}`,
      bootstrap: { url, data: null, error: null, user: null },
    }
  }

  let data: unknown = null
  let error: string | null = null
  let status = match?.route.path === '*' ? 404 : 200

  if (match?.route.loader) {
    try {
      data = await match.route.loader(match.params, ctx)
    } catch (caught) {
      // A 404 from the API is a real 404 for this URL, not a server fault —
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

  const meta = match?.route.meta(data) ?? { title: 'Appnea', description: '' }
  const initial: RouteState = { url, data, error, loading: false }

  const html = renderToString(
    <StaticRouter location={url}>
      <AuthProvider initialUser={user}>
        <RouteDataProvider initial={initial}>
          <App />
        </RouteDataProvider>
      </AuthProvider>
    </StaticRouter>,
  )

  const head = [
    `<title>${escapeHtml(meta.title)}</title>`,
    `<meta name="description" content="${escapeHtml(meta.description)}" />`,
    `<meta property="og:title" content="${escapeHtml(meta.title)}" />`,
    `<meta property="og:description" content="${escapeHtml(meta.description)}" />`,
    `<meta property="og:type" content="website" />`,
    `<meta name="twitter:card" content="summary_large_image" />`,
    // Signed-in pages are per-visitor; a shared cache must never serve one to
    // someone else.
    user ? `<meta name="robots" content="noindex" />` : '',
  ].filter(Boolean).join('\n    ')

  return { html, head, status, bootstrap: { url, data, error, user } }
}
