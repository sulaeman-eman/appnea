import { vi } from 'vitest'

export const COURSES = [
  {
    id: 1, slug: 'aida-2', title: 'AIDA 2 Freediver', agency: 'aida', level: 'Beginner',
    depthTargetM: 20, durationDays: 3, priceCents: 45000000, currency: 'IDR',
    summary: 'Your first certification.', coverImageUrl: null, availableLocales: [],
  },
]

export const TRIPS = [
  {
    id: 7, slug: 'nusa-penida-fun-dive', title: 'Nusa Penida Fun Dive',
    destination: 'Nusa Penida, Bali', startDate: '2026-10-05', endDate: '2026-10-06',
    capacity: 8, priceCents: 150000000, currency: 'IDR',
    summary: 'Two days of guided fun diving.', coverImageUrl: null, availableLocales: [],
  },
]

export const ARTICLES = [
  {
    id: 3, slug: 'never-dive-alone', title: 'Never Dive Alone', excerpt: 'Buddy up.',
    category: 'safety', publishedAt: '2026-09-01T00:00:00+07:00',
    coverImageUrl: null, availableLocales: [],
  },
]

export const INSTRUCTORS = [
  { id: 1, name: 'Bagus Wirawan', certifications: ['AIDA Instructor'], bio: 'Teaches in Amed.', photoUrl: null },
]

const META = { page: 1, count: 1 }

/**
 * Answers the endpoints the pages call, so a navigation test exercises the real
 * loader path without a server.
 */
export function stubApi() {
  const calls: string[] = []

  const fetchMock = vi.fn(async (input: RequestInfo | URL) => {
    const url = typeof input === 'string' ? input : input.toString()
    calls.push(url)

    const body = (payload: unknown) =>
      new Response(JSON.stringify(payload), {
        status: 200,
        headers: { 'Content-Type': 'application/json' },
      })

    if (url.includes('/api/courses')) return body({ courses: COURSES, meta: META })
    if (url.includes('/api/trips')) return body({ trips: TRIPS, meta: META })
    if (url.includes('/api/articles')) return body({ articles: ARTICLES, meta: META })
    if (url.includes('/api/instructors')) return body({ instructors: INSTRUCTORS })
    if (url.includes('/api/search')) return body({ query: 'x', courses: [], articles: [], total: 0 })

    return new Response(JSON.stringify({ error: 'not_stubbed' }), { status: 404 })
  })

  vi.stubGlobal('fetch', fetchMock)
  return { calls, fetchMock }
}
