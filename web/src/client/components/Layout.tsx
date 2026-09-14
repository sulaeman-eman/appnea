import { NavLink, Link, useNavigate } from 'react-router'
import { useState, type FormEvent, type ReactNode } from 'react'
import { useAuth } from '../auth'
import { useLocale } from '../locale'
import { LOCALES, LOCALE_LABEL, type Locale } from '~/shared/i18n'
import type { TranslationKey } from '~/shared/i18n'

const NAV: Array<{ to: string; key: TranslationKey }> = [
  { to: '/courses', key: 'nav.courses' },
  { to: '/trips', key: 'nav.trips' },
  { to: '/instructors', key: 'nav.instructors' },
  { to: '/blog', key: 'nav.blog' },
]

function SearchBox() {
  const { t } = useLocale()
  const navigate = useNavigate()
  const [query, setQuery] = useState('')

  function submit(event: FormEvent) {
    event.preventDefault()
    const trimmed = query.trim()
    if (trimmed) navigate(`/search?q=${encodeURIComponent(trimmed)}`)
  }

  return (
    <form className="search-box" onSubmit={submit} role="search">
      <input
        type="search"
        value={query}
        onChange={(event) => setQuery(event.target.value)}
        placeholder={t('search.placeholder')}
        aria-label={t('nav.search')}
      />
    </form>
  )
}

function LocaleSwitcher() {
  const { locale, setLocale } = useLocale()

  return (
    <label className="locale-switcher">
      <span className="visually-hidden">Language</span>
      <select value={locale} onChange={(event) => setLocale(event.target.value as Locale)}>
        {LOCALES.map((value) => (
          <option key={value} value={value}>
            {LOCALE_LABEL[value]}
          </option>
        ))}
      </select>
    </label>
  )
}

export default function Layout({ children }: { children: ReactNode }) {
  const { user, logout } = useAuth()
  const { t } = useLocale()
  const navigate = useNavigate()

  async function signOut() {
    await logout()
    navigate('/', { replace: true })
  }

  return (
    <>
      <header className="site-header">
        <div className="wrap">
          <Link to="/" className="brand">Appnea</Link>

          <nav className="site-nav">
            {NAV.map((item) => (
              <NavLink key={item.to} to={item.to} className={({ isActive }) => (isActive ? 'active' : undefined)}>
                {t(item.key)}
              </NavLink>
            ))}

            {user ? (
              <>
                <NavLink to="/bookings" className={({ isActive }) => (isActive ? 'active' : undefined)}>
                  {t('nav.bookings')}
                </NavLink>
                <button type="button" className="link-button on-dark" onClick={signOut}>
                  {t('nav.signOut')} ({user.name.split(' ')[0]})
                </button>
              </>
            ) : (
              <NavLink to="/login" className={({ isActive }) => (isActive ? 'active' : undefined)}>
                {t('nav.signIn')}
              </NavLink>
            )}
          </nav>

          <div className="header-tools">
            <SearchBox />
            <LocaleSwitcher />
          </div>
        </div>
      </header>

      <main>{children}</main>

      <footer className="site-footer">
        <div className="wrap">
          <span>{t('footer.tagline')}</span>
          <span>Amed &middot; Nusa Penida</span>
        </div>
      </footer>
    </>
  )
}
