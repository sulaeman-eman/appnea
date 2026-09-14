import type {
  Article, ArticleDetail, Course, CourseDetail, Instructor,
  Meta, Schedule, ScheduleWithCourse, Trip, TripDetail, User, Booking,
} from './types'

/**
 * Server-side rendering has no browser cookie jar, so the Express layer passes
 * the caller's token down explicitly. In the browser there is no token to pass:
 * the httpOnly cookie rides along automatically and Express turns it into an
 * Authorization header.
 */
export interface RequestContext {
  token?: string | null
  locale?: string | null
}

const baseUrl = (): string =>
  typeof window === 'undefined' ? (process.env.API_ORIGIN ?? 'http://localhost:3000') : ''

export class ApiError extends Error {
  constructor(readonly status: number, message: string, readonly detail?: string) {
    super(message)
    this.name = 'ApiError'
  }
}

/** Appends ?locale= so the API returns the right translation for this visitor. */
function withLocale(path: string, locale?: string | null): string {
  if (!locale) return path
  return `${path}${path.includes('?') ? '&' : '?'}locale=${encodeURIComponent(locale)}`
}

async function request<T>(method: string, path: string, options: {
  ctx?: RequestContext
  body?: unknown
} = {}): Promise<T> {
  const headers: Record<string, string> = { Accept: 'application/json' }
  if (options.body !== undefined) headers['Content-Type'] = 'application/json'
  if (options.ctx?.token) headers.Authorization = `Bearer ${options.ctx.token}`

  const response = await fetch(`${baseUrl()}/api${withLocale(path, options.ctx?.locale)}`, {
    method,
    headers,
    body: options.body === undefined ? undefined : JSON.stringify(options.body),
  })

  if (response.status === 204) return undefined as T

  const payload = await response.json().catch(() => null)

  if (!response.ok) {
    const detail = (payload as { detail?: string; error?: string } | null)
    throw new ApiError(
      response.status,
      detail?.error ?? `${method} /api${path} responded ${response.status}`,
      detail?.detail,
    )
  }

  return payload as T
}

const get = <T>(path: string, ctx?: RequestContext) => request<T>('GET', path, { ctx })

export const api = {
  courses: (ctx?: RequestContext) => get<{ courses: Course[]; meta: Meta }>('/courses', ctx),
  course: (slug: string, ctx?: RequestContext) =>
    get<{ course: CourseDetail }>(`/courses/${encodeURIComponent(slug)}`, ctx),
  schedules: (courseId?: number, ctx?: RequestContext) =>
    get<{ schedules: ScheduleWithCourse[]; meta: Meta }>(
      courseId ? `/schedules?course_id=${courseId}` : '/schedules', ctx,
    ),
  schedule: (id: string | number, ctx?: RequestContext) =>
    get<{ schedule: ScheduleWithCourse }>(`/schedules/${encodeURIComponent(String(id))}`, ctx),
  instructors: (ctx?: RequestContext) => get<{ instructors: Instructor[] }>('/instructors', ctx),
  trips: (ctx?: RequestContext) => get<{ trips: Trip[]; meta: Meta }>('/trips', ctx),
  trip: (slug: string, ctx?: RequestContext) =>
    get<{ trip: TripDetail }>(`/trips/${encodeURIComponent(slug)}`, ctx),
  articles: (ctx?: RequestContext) => get<{ articles: Article[]; meta: Meta }>('/articles', ctx),
  article: (slug: string, ctx?: RequestContext) =>
    get<{ article: ArticleDetail }>(`/articles/${encodeURIComponent(slug)}`, ctx),

  search: (query: string, ctx?: RequestContext) =>
    get<{ query: string; courses: Course[]; articles: Article[]; total: number }>(
      `/search?q=${encodeURIComponent(query)}`, ctx,
    ),

  me: (ctx?: RequestContext) => get<{ user: User }>('/auth/me', ctx),
  bookings: (ctx?: RequestContext) => get<{ bookings: Booking[] }>('/bookings', ctx),

  // These three are handled by Express itself, not proxied: it holds the token
  // back and sets the session cookie instead of returning it to the browser.
  login: (email: string, password: string) =>
    request<{ user: User }>('POST', '/auth/login', { body: { session: { email, password } } }),
  signup: (input: { name: string; email: string; password: string }) =>
    request<{ user: User }>('POST', '/auth/signup', { body: { user: input } }),
  logout: () => request<void>('POST', '/auth/logout'),

  createBooking: (input: { scheduleId: number; participants: number; notes: string }) =>
    request<{ booking: Booking }>('POST', '/bookings', {
      body: { booking: { schedule_id: input.scheduleId, participants: input.participants, notes: input.notes } },
    }),
  cancelBooking: (id: number) => request<{ booking: Booking }>('DELETE', `/bookings/${id}`),
}

export type { Schedule }
