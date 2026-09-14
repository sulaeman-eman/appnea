import { createContext, useCallback, useContext, useMemo, useState, type ReactNode } from 'react'
import { LOCALE_COOKIE, DEFAULT_LOCALE, translate, type Locale, type TranslationKey } from '~/shared/i18n'

interface LocaleValue {
  locale: Locale
  setLocale: (next: Locale) => void
  t: (key: TranslationKey) => string
}

const LocaleContext = createContext<LocaleValue | null>(null)

export function LocaleProvider({ initial, children }: { initial: Locale; children: ReactNode }) {
  const [locale, setLocaleState] = useState<Locale>(initial)

  const setLocale = useCallback((next: Locale) => {
    setLocaleState(next)

    if (typeof document !== 'undefined') {
      // Readable by the server on the next request, so SSR renders in the same
      // language the visitor just picked. A year is long enough that nobody has
      // to choose twice.
      document.cookie = `${LOCALE_COOKIE}=${next}; path=/; max-age=31536000; samesite=lax`
      document.documentElement.lang = next
    }
  }, [])

  const value = useMemo<LocaleValue>(() => ({
    locale,
    setLocale,
    t: (key) => translate(locale, key),
  }), [locale, setLocale])

  return <LocaleContext.Provider value={value}>{children}</LocaleContext.Provider>
}

export function useLocale(): LocaleValue {
  const value = useContext(LocaleContext)
  if (!value) return { locale: DEFAULT_LOCALE, setLocale: () => {}, t: (key) => translate(DEFAULT_LOCALE, key) }
  return value
}

/** Shorthand for components that only need the translator. */
export function useT(): (key: TranslationKey) => string {
  return useLocale().t
}
