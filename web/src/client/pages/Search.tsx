import { useEffect, useState, type FormEvent } from 'react'
import { Link, useNavigate, useSearchParams } from 'react-router'
import { useRouteState } from '../data'
import { useLocale } from '../locale'
import CourseCard from '../components/CourseCard'
import { Empty, ErrorState, Loading } from '../components/states'
import type { Article, Course } from '~/shared/types'
import { formatDate } from '~/shared/format'

interface SearchResults {
  query: string
  courses: Course[]
  articles: Article[]
  total: number
}

export default function SearchPage() {
  const { data, error, loading } = useRouteState()
  const { t } = useLocale()
  const navigate = useNavigate()
  const [searchParams] = useSearchParams()

  const urlQuery = searchParams.get('q') ?? ''
  const [draft, setDraft] = useState(urlQuery)

  // Keep the box in step when the URL changes underneath it, for instance when
  // the visitor uses the back button.
  useEffect(() => setDraft(urlQuery), [urlQuery])

  const results = data as SearchResults | null

  function submit(event: FormEvent) {
    event.preventDefault()
    const trimmed = draft.trim()
    navigate(trimmed ? `/search?q=${encodeURIComponent(trimmed)}` : '/search')
  }

  return (
    <>
      <div className="page-head">
        <div className="wrap">
          <h1>{t('search.heading')}</h1>
          <p>{t('search.intro')}</p>

          <form className="search-page-form" onSubmit={submit} role="search">
            <input
              type="search"
              value={draft}
              onChange={(event) => setDraft(event.target.value)}
              placeholder={t('search.placeholder')}
              aria-label={t('nav.search')}
              autoFocus
            />
            <button type="submit" className="button">{t('nav.search')}</button>
          </form>
        </div>
      </div>

      <section className="block">
        <div className="wrap">
          {error && <ErrorState message={error} />}
          {loading && <Loading what={t('search.heading').toLowerCase()} />}

          {!loading && !error && results && !results.query && (
            <Empty message={t('search.prompt')} />
          )}

          {!loading && !error && results?.query && results.total === 0 && (
            <Empty message={t('search.none')} />
          )}

          {!loading && !error && results?.query && results.total > 0 && (
            <>
              <p className="search-summary">
                {t('search.resultsFor')} <strong>{results.query}</strong>
              </p>

              {results.courses.length > 0 && (
                <>
                  <h2>{t('search.coursesHeading')}</h2>
                  <div className="grid">
                    {results.courses.map((course) => <CourseCard key={course.id} course={course} />)}
                  </div>
                </>
              )}

              {results.articles.length > 0 && (
                <>
                  <h2>{t('search.articlesHeading')}</h2>
                  <div className="grid">
                    {results.articles.map((article) => (
                      <Link key={article.id} to={`/blog/${article.slug}`} className="card">
                        {article.coverImageUrl && (
                          <img className="card-image" src={article.coverImageUrl} alt="" loading="lazy" />
                        )}
                        <span className="tag">{article.category}</span>
                        <h3>{article.title}</h3>
                        <p>{article.excerpt}</p>
                        <div className="card-meta"><span>{formatDate(article.publishedAt)}</span></div>
                      </Link>
                    ))}
                  </div>
                </>
              )}
            </>
          )}
        </div>
      </section>
    </>
  )
}
