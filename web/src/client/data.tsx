import { createContext, useContext, useEffect, useState, type ReactNode } from 'react'
import { useLocation } from 'react-router'
import { findRoute } from './routes'

export interface RouteState {
  url: string
  data: unknown
  error: string | null
  loading: boolean
}

const RouteDataContext = createContext<RouteState | null>(null)

/**
 * Holds the data for the route currently on screen.
 *
 * The first render reuses whatever the server already loaded, so hydration
 * matches the server HTML exactly. Every later navigation refetches, because
 * only the initial URL has server-supplied data.
 */
export function RouteDataProvider({ initial, children }: { initial: RouteState; children: ReactNode }) {
  const location = useLocation()
  const [state, setState] = useState<RouteState>(initial)

  useEffect(() => {
    const url = location.pathname + location.search
    if (url === state.url && !state.loading) return

    const match = findRoute(location.pathname)
    if (!match?.route.loader) {
      setState({ url, data: null, error: null, loading: false })
      return
    }

    let cancelled = false
    setState((previous) => ({ ...previous, loading: true }))

    match.route
      .loader(match.params)
      .then((data) => {
        if (!cancelled) setState({ url, data, error: null, loading: false })
      })
      .catch((error: unknown) => {
        if (!cancelled) {
          setState({ url, data: null, loading: false, error: error instanceof Error ? error.message : 'Request failed' })
        }
      })

    return () => {
      cancelled = true
    }
    // state.url is intentionally excluded: including it would re-run the effect
    // when the fetch resolves and set up an infinite reload loop.
    // eslint-disable-next-line react-hooks/exhaustive-deps
  }, [location.pathname, location.search])

  return <RouteDataContext.Provider value={state}>{children}</RouteDataContext.Provider>
}

export function useRouteState(): RouteState {
  const state = useContext(RouteDataContext)
  if (!state) throw new Error('useRouteState must be used inside RouteDataProvider')
  return state
}

/** Returns the loaded data for this route, or null while it is still in flight. */
export function useLoaderData<T>(): T | null {
  return useRouteState().data as T | null
}
