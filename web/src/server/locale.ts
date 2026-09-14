import type { Request } from 'express'
import { DEFAULT_LOCALE, LOCALES, LOCALE_COOKIE, isLocale, type Locale } from '../shared/i18n.js'

/**
 * Picks the language for a server-rendered page: the visitor's saved choice
 * first, then what their browser asks for, then English.
 *
 * Resolving this before rendering matters — the alternative is rendering in
 * English and swapping on the client, which flashes and gives crawlers the
 * wrong language.
 */
export function resolveLocale(req: Request): Locale {
  const fromCookie = readCookie(req, LOCALE_COOKIE)
  if (isLocale(fromCookie)) return fromCookie

  const fromHeader = (req.headers['accept-language'] ?? '')
    .toString()
    .split(',')
    .map((part) => part.split(';')[0]?.trim().toLowerCase().split('-')[0])
    .find((tag) => tag && (LOCALES as readonly string[]).includes(tag))

  return isLocale(fromHeader) ? fromHeader : DEFAULT_LOCALE
}

function readCookie(req: Request, name: string): string | null {
  const raw = req.headers.cookie
  if (!raw) return null

  for (const part of raw.split(';')) {
    const eq = part.indexOf('=')
    if (eq === -1) continue
    if (part.slice(0, eq).trim() === name) return decodeURIComponent(part.slice(eq + 1).trim())
  }
  return null
}
