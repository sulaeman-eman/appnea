import express from 'express'
import compression from 'compression'
import fs from 'node:fs/promises'
import path from 'node:path'
import { fileURLToPath } from 'node:url'
import { proxyToApi } from './proxy.js'
import { login, signup, logout, readSessionToken } from './auth.js'

const __dirname = path.dirname(fileURLToPath(import.meta.url))
const root = path.resolve(__dirname, '../..')

const isProd = process.env.NODE_ENV === 'production'
const port = Number(process.env.PORT ?? 5173)

interface RenderResult {
  html: string
  head: string
  status: number
  redirect?: string
  bootstrap: { url: string; data: unknown; error: string | null; user: unknown }
}

type RenderFn = (url: string, token?: string | null) => Promise<RenderResult>

/**
 * Serialises the SSR payload for a <script> tag.
 *
 * `</script>` inside any string would close the tag early and turn page content
 * into markup, and U+2028/U+2029 are valid JSON but illegal in a JS string
 * literal, so both are escaped rather than trusted.
 */
function serialize(value: unknown): string {
  return JSON.stringify(value)
    .replace(/</g, '\\u003c')
    .replace(/\u2028/g, '\\u2028')
    .replace(/\u2029/g, '\\u2029')
}

async function createServer() {
  const app = express()
  app.use(compression())

  // Auth is handled here rather than proxied: Express keeps the token in an
  // httpOnly cookie and returns only the user, so client JavaScript never holds
  // a credential. These must be registered before the catch-all /api proxy.
  app.post('/api/auth/login', express.json({ limit: '16kb' }), login)
  app.post('/api/auth/signup', express.json({ limit: '16kb' }), signup)
  app.post('/api/auth/logout', logout)

  // Raw body so the proxy can forward JSON, forms, and uploads untouched.
  app.use('/api', express.raw({ type: '*/*', limit: '25mb' }), proxyToApi)

  let template = ''
  let render: RenderFn | undefined
  let vite: Awaited<ReturnType<typeof import('vite').createServer>> | undefined

  if (isProd) {
    const sirv = (await import('sirv')).default
    app.use('/assets', sirv(path.join(root, 'dist/client/assets'), { immutable: true, maxAge: 31536000 }))
    template = await fs.readFile(path.join(root, 'dist/client/index.html'), 'utf-8')
    render = (await import(path.join(root, 'dist/server/entry-server.js'))).render as RenderFn
  } else {
    const { createServer: createViteServer } = await import('vite')
    vite = await createViteServer({ root, server: { middlewareMode: true }, appType: 'custom' })
    app.use(vite.middlewares)
  }

  app.use(async (req, res, next) => {
    try {
      let html = template
      let renderFn = render

      if (!isProd && vite) {
        html = await vite.transformIndexHtml(
          req.originalUrl,
          await fs.readFile(path.join(root, 'index.html'), 'utf-8'),
        )
        renderFn = (await vite.ssrLoadModule('/src/client/entry-server.tsx')).render as RenderFn
      }

      if (!renderFn) throw new Error('SSR entry not loaded')

      const rendered = await renderFn(req.originalUrl, readSessionToken(req))

      if (rendered.redirect) {
        res.redirect(302, rendered.redirect)
        return
      }
      const bootstrap = `<script>window.__APPNEA__ = ${serialize(rendered.bootstrap)}</script>`

      res
        .status(rendered.status)
        .set({
          'Content-Type': 'text/html',
          // A page rendered for a signed-in visitor must never be reused for
          // anyone else by a proxy or CDN.
          'Cache-Control': rendered.bootstrap.user ? 'private, no-store' : 'no-cache',
        })
        .send(
          html
            .replace('<!--app-head-->', rendered.head)
            .replace('<!--app-html-->', rendered.html)
            .replace('<!--app-data-->', bootstrap),
        )
    } catch (error) {
      vite?.ssrFixStacktrace(error as Error)
      next(error)
    }
  })

  app.listen(port, () => {
    console.log(`[appnea/web] ${isProd ? 'production' : 'dev'} server on http://localhost:${port}`)
  })
}

createServer()
