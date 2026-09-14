import type { ComponentType } from 'react'
import { api, type RequestContext } from '~/shared/api'
import type { ArticleDetail, CourseDetail, TripDetail, ScheduleWithCourse } from '~/shared/types'

import Home from './pages/Home'
import Courses from './pages/Courses'
import CourseDetailPage from './pages/CourseDetail'
import Instructors from './pages/Instructors'
import Trips from './pages/Trips'
import TripDetailPage from './pages/TripDetail'
import Blog from './pages/Blog'
import ArticlePage from './pages/Article'
import Login from './pages/Login'
import Signup from './pages/Signup'
import Bookings from './pages/Bookings'
import BookSchedule from './pages/BookSchedule'
import NotFound from './pages/NotFound'

export interface PageMeta {
  title: string
  description: string
}

export interface RouteDef {
  path: string
  Component: ComponentType
  loader?: (params: Record<string, string>, ctx?: RequestContext) => Promise<unknown>
  meta: (data: unknown) => PageMeta
  /** Rendered only for a signed-in visitor; anyone else is sent to /login. */
  requiresAuth?: boolean
}

const SITE = 'Appnea'

export const routes: RouteDef[] = [
  {
    path: '/',
    Component: Home,
    loader: async (_params, ctx) => {
      const [{ courses }, { articles }] = await Promise.all([api.courses(ctx), api.articles(ctx)])
      return { courses: courses.slice(0, 3), articles: articles.slice(0, 3) }
    },
    meta: () => ({
      title: `${SITE} — Freediving courses in Bali`,
      description: 'AIDA and Molchanovs freediving courses, depth camps, and guided fun dives in Bali.',
    }),
  },
  {
    path: '/courses',
    Component: Courses,
    loader: async (_params, ctx) => api.courses(ctx),
    meta: () => ({
      title: `Courses — ${SITE}`,
      description: 'Every freediving certification we teach, from your first breath-hold to instructor level.',
    }),
  },
  {
    path: '/courses/:slug',
    Component: CourseDetailPage,
    loader: async (params, ctx) => api.course(params.slug!, ctx),
    meta: (data) => {
      const course = (data as { course?: CourseDetail } | null)?.course
      return {
        title: course ? `${course.title} — ${SITE}` : `Course — ${SITE}`,
        description: course?.summary ?? '',
      }
    },
  },
  {
    path: '/instructors',
    Component: Instructors,
    loader: async (_params, ctx) => api.instructors(ctx),
    meta: () => ({
      title: `Instructors — ${SITE}`,
      description: 'The people who will be on the line with you.',
    }),
  },
  {
    path: '/trips',
    Component: Trips,
    loader: async (_params, ctx) => api.trips(ctx),
    meta: () => ({
      title: `Trips — ${SITE}`,
      description: 'Guided fun dives and depth camps around Bali and Nusa Penida.',
    }),
  },
  {
    path: '/trips/:slug',
    Component: TripDetailPage,
    loader: async (params, ctx) => api.trip(params.slug!, ctx),
    meta: (data) => {
      const trip = (data as { trip?: TripDetail } | null)?.trip
      return {
        title: trip ? `${trip.title} — ${SITE}` : `Trip — ${SITE}`,
        description: trip?.summary ?? '',
      }
    },
  },
  {
    path: '/blog',
    Component: Blog,
    loader: async (_params, ctx) => api.articles(ctx),
    meta: () => ({
      title: `Blog — ${SITE}`,
      description: 'Technique, safety, and travel notes from the Appnea team.',
    }),
  },
  {
    path: '/blog/:slug',
    Component: ArticlePage,
    loader: async (params, ctx) => api.article(params.slug!, ctx),
    meta: (data) => {
      const article = (data as { article?: ArticleDetail } | null)?.article
      return {
        title: article ? `${article.title} — ${SITE}` : `Article — ${SITE}`,
        description: article?.excerpt ?? '',
      }
    },
  },
  {
    path: '/login',
    Component: Login,
    meta: () => ({ title: `Sign in — ${SITE}`, description: 'Sign in to manage your bookings.' }),
  },
  {
    path: '/signup',
    Component: Signup,
    meta: () => ({ title: `Create an account — ${SITE}`, description: 'Create an Appnea account to book a course.' }),
  },
  {
    path: '/bookings',
    Component: Bookings,
    requiresAuth: true,
    loader: async (_params, ctx) => api.bookings(ctx),
    meta: () => ({ title: `Your bookings — ${SITE}`, description: '' }),
  },
  {
    path: '/book/:scheduleId',
    Component: BookSchedule,
    requiresAuth: true,
    loader: async (params, ctx) => api.schedule(params.scheduleId!, ctx),
    meta: (data) => {
      const schedule = (data as { schedule?: ScheduleWithCourse } | null)?.schedule
      return {
        title: schedule ? `Book ${schedule.course.title} — ${SITE}` : `Book — ${SITE}`,
        description: '',
      }
    },
  },
  {
    path: '*',
    Component: NotFound,
    meta: () => ({ title: `Not found — ${SITE}`, description: '' }),
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
