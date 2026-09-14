import { describe, it, expect, beforeEach, afterEach, vi } from 'vitest'
import { render, screen, waitFor } from '@testing-library/react'
import userEvent from '@testing-library/user-event'
import { MemoryRouter } from 'react-router'
import App from './App'
import { RouteDataProvider, type RouteState } from './data'
import { AuthProvider } from './auth'
import { LocaleProvider } from './locale'
import { routeKey } from './routes'
import { stubApi, COURSES } from '../test/api-stub'

/**
 * Client-side navigation, which the SSR checks cannot reach: those fetch each
 * URL fresh, so they never exercise the transition from one route's data to the
 * next one's.
 */
function mount(url: string, data: unknown) {
  return render(
    <MemoryRouter initialEntries={[url]}>
      <LocaleProvider initial="en">
        <AuthProvider initialUser={null}>
          <RouteDataProvider
            initial={{ key: routeKey(url, 'en'), data, error: null, loading: false } satisfies RouteState}
          >
            <App />
          </RouteDataProvider>
        </AuthProvider>
      </LocaleProvider>
    </MemoryRouter>,
  )
}

describe('client-side navigation', () => {
  beforeEach(() => {
    stubApi()
  })

  afterEach(() => {
    vi.unstubAllGlobals()
    vi.restoreAllMocks()
  })

  it('renders the server-supplied data on first paint', async () => {
    mount('/courses', { courses: COURSES, meta: { page: 1, count: 1 } })
    expect(await screen.findByText('AIDA 2 Freediver')).toBeTruthy()
  })

  it('shows the next page without a manual reload', async () => {
    const user = userEvent.setup()
    mount('/courses', { courses: COURSES, meta: { page: 1, count: 1 } })

    await screen.findByText('AIDA 2 Freediver')
    await user.click(screen.getByRole('link', { name: 'Trips' }))

    // Before the fix this blew up: the provider kept the courses payload while
    // the trips loader was in flight, and the trips page read `.trips.length`
    // off it, throwing and unmounting the whole tree.
    expect(await screen.findByText('Nusa Penida Fun Dive')).toBeTruthy()
  })

  it('never hands a page the previous route data', async () => {
    const user = userEvent.setup()
    mount('/courses', { courses: COURSES, meta: { page: 1, count: 1 } })

    await screen.findByText('AIDA 2 Freediver')
    await user.click(screen.getByRole('link', { name: 'Blog' }))

    // The old course title must be gone the moment we leave the route, not
    // linger underneath the next page.
    await waitFor(() => expect(screen.queryByText('AIDA 2 Freediver')).toBeNull())
    expect(await screen.findByText('Never Dive Alone')).toBeTruthy()
  })

  it('walks through several pages in a row', async () => {
    const user = userEvent.setup()
    mount('/', { courses: COURSES, articles: [] })

    await user.click(screen.getByRole('link', { name: 'Instructors' }))
    expect(await screen.findByText('Bagus Wirawan')).toBeTruthy()

    await user.click(screen.getByRole('link', { name: 'Trips' }))
    expect(await screen.findByText('Nusa Penida Fun Dive')).toBeTruthy()

    await user.click(screen.getByRole('link', { name: 'Courses' }))
    expect(await screen.findByText('AIDA 2 Freediver')).toBeTruthy()
  })

  it('does not refetch what the server already sent', async () => {
    const { calls } = stubApi()
    mount('/courses', { courses: COURSES, meta: { page: 1, count: 1 } })

    await screen.findByText('AIDA 2 Freediver')

    // Hydration reuses the SSR payload. A fetch here would mean every first
    // paint costs a second round trip for data the page already has.
    expect(calls).toEqual([])
  })

  it('refetches when the language changes', async () => {
    const user = userEvent.setup()
    const { calls } = stubApi()
    mount('/courses', { courses: COURSES, meta: { page: 1, count: 1 } })

    await screen.findByText('AIDA 2 Freediver')
    await user.selectOptions(screen.getByRole('combobox'), 'id')

    await waitFor(() => expect(calls.some((url) => url.includes('locale=id'))).toBe(true))
  })
})
