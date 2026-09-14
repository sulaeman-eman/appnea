import type { Request, Response, CookieOptions } from 'express'

const API_ORIGIN = process.env.API_ORIGIN ?? 'http://localhost:3000'
export const SESSION_COOKIE = process.env.SESSION_COOKIE ?? 'appnea_session'

const SEVEN_DAYS_MS = 7 * 24 * 60 * 60 * 1000

/**
 * httpOnly keeps the token out of reach of any script on the page, so an XSS
 * bug cannot read it. sameSite=lax stops another site from riding the cookie on
 * a cross-site POST. secure is on outside development, where TLS is expected.
 */
function cookieOptions(): CookieOptions {
  return {
    httpOnly: true,
    sameSite: 'lax',
    secure: process.env.NODE_ENV === 'production',
    path: '/',
    maxAge: SEVEN_DAYS_MS,
  }
}

interface RailsAuthResponse {
  user?: unknown
  token?: string
  error?: string
  details?: unknown
  detail?: string
}

/**
 * Calls a Rails auth endpoint, keeps the token server-side in a cookie, and
 * returns only the user to the browser.
 *
 * This is the whole point of the BFF: proxying these endpoints blindly would
 * put the JWT in a JSON body that client JavaScript can read.
 */
async function exchange(req: Request, res: Response, path: string): Promise<void> {
  let upstream: globalThis.Response
  let body: RailsAuthResponse

  try {
    upstream = await fetch(`${API_ORIGIN}${path}`, {
      method: 'POST',
      headers: { 'Content-Type': 'application/json', Accept: 'application/json' },
      body: JSON.stringify(req.body ?? {}),
    })
    body = (await upstream.json()) as RailsAuthResponse
  } catch (error) {
    console.error(`[auth] ${path} failed:`, error)
    res.status(502).json({ error: 'upstream_unavailable' })
    return
  }

  if (!upstream.ok || !body.token) {
    // Pass the failure through unchanged, minus anything token-shaped.
    const { token: _token, ...safe } = body
    res.status(upstream.status).json(safe)
    return
  }

  res.cookie(SESSION_COOKIE, body.token, cookieOptions())
  res.status(upstream.status).json({ user: body.user })
}

export const login = (req: Request, res: Response) => exchange(req, res, '/api/auth/login')
export const signup = (req: Request, res: Response) => exchange(req, res, '/api/auth/signup')

export function logout(_req: Request, res: Response): void {
  // clearCookie must be given the same attributes the cookie was set with,
  // or the browser keeps the original and the user stays signed in.
  res.clearCookie(SESSION_COOKIE, { ...cookieOptions(), maxAge: undefined })
  res.status(204).end()
}

/** Reads the session token from the request cookie header. */
export function readSessionToken(req: Request): string | null {
  const raw = req.headers.cookie
  if (!raw) return null

  for (const part of raw.split(';')) {
    const eq = part.indexOf('=')
    if (eq === -1) continue
    if (part.slice(0, eq).trim() === SESSION_COOKIE) {
      return decodeURIComponent(part.slice(eq + 1).trim())
    }
  }
  return null
}
