import type { ComponentType } from 'react'
import { api, type RequestContext } from '~/shared/api'
import type { Locale } from '~/shared/i18n'
import type { ArticleDetail, CourseDetail, ScheduleWithCourse, TripDetail } from '~/shared/types'

import Home from './pages/Home'
import Courses from './pages/Courses'
import CourseDetailPage from './pages/CourseDetail'
import Instructors from './pages/Instructors'
import Trips from './pages/Trips'
import TripDetailPage from './pages/TripDetail'
import Blog from './pages/Blog'
import ArticlePage from './pages/Article'
import SearchPage from './pages/Search'
import Login from './pages/Login'
import Signup from './pages/Signup'
import Bookings from './pages/Bookings'
import BookSchedule from './pages/BookSchedule'
import NotFound from './pages/NotFound'

export interface PageMeta {
  title: string
  description: string
}

export interface LoaderArgs {
  params: Record<string, string>
  /** Query string of the URL being rendered, for routes driven by ?q= and friends. */
  query: URLSearchParams
  /** Carries the locale, and on the server the caller's token. */
  ctx: RequestContext
}

export interface RouteDef {
  path: string
  Component: ComponentType
  loader?: (args: LoaderArgs) => Promise<unknown>
  meta: (data: unknown, locale: Locale) => PageMeta
  /** Rendered only for a signed-in visitor; anyone else is sent to /login. */
  requiresAuth?: boolean
}

const SITE = 'Appnea'

export const routes: RouteDef[] = [
  {
    path: '/',
    Component: Home,
    loader: async ({ ctx }) => {
      const [{ courses }, { articles }] = await Promise.all([api.courses(ctx), api.articles(ctx)])
      return { courses: courses.slice(0, 3), articles: articles.slice(0, 3) }
    },
    meta: (_data, locale) => ({
      title: locale === 'id' ? `${SITE} - Kursus freediving di Bali` : `${SITE} - Freediving courses in Bali`,
      description: locale === 'id'
        ? 'Kursus freediving AIDA dan Molchanovs, depth camp, dan fun dive berpemandu di Bali.'
        : 'AIDA and Molchanovs freediving courses, depth camps, and guided fun dives in Bali.',
    }),
  },
  {
    path: '/courses',
    Component: Courses,
    loader: async ({ ctx }) => api.courses(ctx),
    meta: (_data, locale) => ({
      title: locale === 'id' ? `Kursus - ${SITE}` : `Courses - ${SITE}`,
      description: locale === 'id'
        ? 'Semua sertifikasi freediving yang kami ajarkan.'
        : 'Every freediving certification we teach, from your first breath-hold to instructor level.',
    }),
  },
  {
    path: '/courses/:slug',
    Component: CourseDetailPage,
    loader: async ({ params, ctx }) => api.course(params.slug!, ctx),
    meta: (data) => {
      const course = (data as { course?: CourseDetail } | null)?.course
      return {
        title: course ? `${course.title} - ${SITE}` : `Course - ${SITE}`,
        description: course?.summary ?? '',
      }
    },
  },
  {
    path: '/instructors',
    Component: Instructors,
    loader: async ({ ctx }) => api.instructors(ctx),
    meta: (_data, locale) => ({
      title: locale === 'id' ? `Instruktur - ${SITE}` : `Instructors - ${SITE}`,
      description: locale === 'id'
        ? 'Orang-orang yang akan menemanimu di tali.'
        : 'The people who will be on the line with you.',
    }),
  },
  {
    path: '/trips',
    Component: Trips,
    loader: async ({ ctx }) => api.trips(ctx),
    meta: (_data, locale) => ({
      title: locale === 'id' ? `Trip - ${SITE}` : `Trips - ${SITE}`,
      description: locale === 'id'
        ? 'Fun dive berpemandu dan depth camp di sekitar Bali dan Nusa Penida.'
        : 'Guided fun dives and depth camps around Bali and Nusa Penida.',
    }),
  },
  {
    path: '/trips/:slug',
    Component: TripDetailPage,
    loader: async ({ params, ctx }) => api.trip(params.slug!, ctx),
    meta: (data) => {
      const trip = (data as { trip?: TripDetail } | null)?.trip
      return {
        title: trip ? `${trip.title} - ${SITE}` : `Trip - ${SITE}`,
        description: trip?.summary ?? '',
      }
    },
  },
  {
    path: '/blog',
    Component: Blog,
    loader: async ({ ctx }) => api.articles(ctx),
    meta: (_data, locale) => ({
      title: `Blog - ${SITE}`,
      description: locale === 'id'
        ? 'Catatan teknik, keselamatan, dan perjalanan dari tim Appnea.'
        : 'Technique, safety, and travel notes from the Appnea team.',
    }),
  },
  {
    path: '/blog/:slug',
    Component: ArticlePage,
    loader: async ({ params, ctx }) => api.article(params.slug!, ctx),
    meta: (data) => {
      const article = (data as { article?: ArticleDetail } | null)?.article
      return {
        title: article ? `${article.title} - ${SITE}` : `Article - ${SITE}`,
        description: article?.excerpt ?? '',
      }
    },
  },
  {
    path: '/search',
    Component: SearchPage,
    loader: async ({ query, ctx }) => {
      const q = query.get('q')?.trim()
      if (!q) return { query: '', courses: [], articles: [], total: 0 }
      return api.search(q, ctx)
    },
    meta: (data, locale) => {
      const result = data as { query?: string } | null
      const label = locale === 'id' ? 'Pencarian' : 'Search'
      return {
        title: result?.query ? `${label}: ${result.query} - ${SITE}` : `${label} - ${SITE}`,
        description: '',
      }
    },
  },
  {
    path: '/login',
    Component: Login,
    meta: (_data, locale) => ({
      title: locale === 'id' ? `Masuk - ${SITE}` : `Sign in - ${SITE}`,
      description: '',
    }),
  },
  {
    path: '/signup',
    Component: Signup,
    meta: (_data, locale) => ({
      title: locale === 'id' ? `Buat akun - ${SITE}` : `Create an account - ${SITE}`,
      description: '',
    }),
  },
  {
    path: '/bookings',
    Component: Bookings,
    requiresAuth: true,
    loader: async ({ ctx }) => api.bookings(ctx),
    meta: (_data, locale) => ({
      title: locale === 'id' ? `Booking kamu - ${SITE}` : `Your bookings - ${SITE}`,
      description: '',
    }),
  },
  {
    path: '/book/:scheduleId',
    Component: BookSchedule,
    requiresAuth: true,
    loader: async ({ params, ctx }) => api.schedule(params.scheduleId!, ctx),
    meta: (data, locale) => {
      const schedule = (data as { schedule?: ScheduleWithCourse } | null)?.schedule
      const label = locale === 'id' ? 'Booking' : 'Book'
      return {
        title: schedule ? `${label} ${schedule.course.title} - ${SITE}` : `${label} - ${SITE}`,
        description: '',
      }
    },
  },
  {
    path: '*',
    Component: NotFound,
    meta: (_data, locale) => ({
      title: locale === 'id' ? `Tidak ditemukan - ${SITE}` : `Not found - ${SITE}`,
      description: '',
    }),
  },
]

export interface RouteMatch {
  route: RouteDef
  params: Record<string, string>
}

/** Matches a pathname against the table above, honouring :params and the * fallback. */
export function findRoute(pathname: string): RouteMatch | null {
  const segments = pathname.replace(/\/+$/, '').split('/').filter(Boolean)

  for (const route of routes) {
    if (route.path === '*') continue

    const pattern = route.path.replace(/\/+$/, '').split('/').filter(Boolean)
    if (pattern.length !== segments.length) continue

    const params: Record<string, string> = {}
    const matched = pattern.every((part, index) => {
      const segment = segments[index]!
      if (part.startsWith(':')) {
        params[part.slice(1)] = decodeURIComponent(segment)
        return true
      }
      return part === segment
    })

    if (matched) return { route, params }
  }

  const fallback = routes.find((route) => route.path === '*')
  return fallback ? { route: fallback, params: {} } : null
}

/**
 * Identity of a rendered page. The locale is part of it because switching
 * language must refetch: the translated text comes from the API, not from the
 * client bundle.
 */
export function routeKey(url: string, locale: Locale): string {
  return `${url} ${locale}`
}
