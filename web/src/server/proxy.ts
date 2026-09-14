import type { Request, Response } from 'express'
import { readSessionToken } from './auth.js'

const API_ORIGIN = process.env.API_ORIGIN ?? 'http://localhost:3000'

/** Headers that belong to the Express<->browser hop and must not be forwarded. */
const HOP_BY_HOP = new Set([
  'connection',
  'keep-alive',
  'transfer-encoding',
  'upgrade',
  'host',
  'content-length',
  'cookie',
])

/**
 * Forwards /api/* to Rails.
 *
 * The JWT lives in an httpOnly cookie the browser cannot read. We translate it
 * into an Authorization header here, so the token never reaches client JS.
 */
export async function proxyToApi(req: Request, res: Response): Promise<void> {
  const target = new URL(req.originalUrl, API_ORIGIN)

  const headers = new Headers()
  for (const [key, value] of Object.entries(req.headers)) {
    if (value === undefined || HOP_BY_HOP.has(key)) continue
    headers.set(key, Array.isArray(value) ? value.join(', ') : value)
  }

  const token = readSessionToken(req)
  if (token) headers.set('authorization', `Bearer ${token}`)

  const hasBody = req.method !== 'GET' && req.method !== 'HEAD'

  let upstream: globalThis.Response
  try {
    upstream = await fetch(target, {
      method: req.method,
      headers,
      body: hasBody ? new Uint8Array(req.body as Buffer) : undefined,
      redirect: 'manual',
    })
  } catch (error) {
    console.error(`[proxy] ${req.method} ${target.pathname} failed:`, error)
    res.status(502).json({ error: 'upstream_unavailable' })
    return
  }

  res.status(upstream.status)
  upstream.headers.forEach((value, key) => {
    if (HOP_BY_HOP.has(key) || key === 'content-encoding') return
    res.setHeader(key, value)
  })
  res.send(Buffer.from(await upstream.arrayBuffer()))
}
