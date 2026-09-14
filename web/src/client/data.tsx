import { createContext, useContext, useEffect, useMemo, useRef, useState, type ReactNode } from 'react'
import { useLocation } from 'react-router'
import { findRoute, routeKey } from './routes'
import { useLocale } from './locale'

export interface RouteState {
  /** routeKey(url, locale) of the data currently held. */
  key: string
  data: unknown
  error: string | null
  loading: boolean
}

const RouteDataContext = createContext<RouteState | null>(null)

/**
 * Holds the data for the route currently on screen.
 *
 * The first render reuses whatever the server already loaded, so hydration
 * matches the server HTML exactly. Every later navigation refetches, and so
 * does a language switch, because the translated text comes from the API.
 */
export function RouteDataProvider({ initial, children }: { initial: RouteState; children: ReactNode }) {
  const location = useLocation()
  const { locale } = useLocale()
  const [state, setState] = useState<RouteState>(initial)

  const url = location.pathname + location.search
  const currentKey = routeKey(url, locale)

  /**
   * Data is only ever exposed to a page whose key it actually belongs to.
   *
   * This has to be decided during render, not in the effect below: the router
   * mounts the next page in the same commit as the navigation, so the effect
   * has not run yet. Handing that page the previous route's payload is not a
   * harmless stale render — each page casts `data` to its own shape, so it
   * would read fields that do not exist and throw.
   */
  const value = useMemo<RouteState>(() => (
    state.key === currentKey
      ? state
      : { key: currentKey, data: null, error: null, loading: true }
  ), [state, currentKey])

  // The key a fetch is currently in flight for, kept in a ref so checking it
  // does not itself cause a render.
  const inFlightKey = useRef<string | null>(null)

  useEffect(() => {
    if (currentKey === state.key || currentKey === inFlightKey.current) return

    const match = findRoute(location.pathname)

    if (!match?.route.loader) {
      inFlightKey.current = null
      setState({ key: currentKey, data: null, error: null, loading: false })
      return
    }

    inFlightKey.current = currentKey
    let cancelled = false

    match.route
      .loader({
        params: match.params,
        query: new URLSearchParams(location.search),
        ctx: { locale },
      })
      .then((data) => {
        if (cancelled) return
        inFlightKey.current = null
        setState({ key: currentKey, data, error: null, loading: false })
      })
      .catch((error: unknown) => {
        if (cancelled) return
        inFlightKey.current = null
        setState({
          key: currentKey,
          data: null,
          loading: false,
          error: error instanceof Error ? error.message : 'Request failed',
        })
      })

    return () => {
      cancelled = true
    }
    // state.key is read but deliberately not a dependency: including it would
    // re-run the effect when the fetch resolves and loop.
    // eslint-disable-next-line react-hooks/exhaustive-deps
  }, [currentKey, location.pathname, location.search, locale])

  return <RouteDataContext.Provider value={value}>{children}</RouteDataContext.Provider>
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
