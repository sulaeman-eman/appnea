import { Link } from 'react-router'
import { useRouteState } from '../data'
import { useLocale } from '../locale'
import { Empty, ErrorState, Loading } from '../components/states'
import type { Article, Meta } from '~/shared/types'
import { formatDate } from '~/shared/format'

export default function Blog() {
  const { data, error, loading } = useRouteState()
  const { t } = useLocale()
  const payload = data as { articles: Article[]; meta: Meta } | null

  return (
    <>
      <div className="page-head">
        <div className="wrap">
          <h1>{t('blog.title')}</h1>
          <p>{t('blog.lead')}</p>
        </div>
      </div>

      <section className="block">
        <div className="wrap">
          {error && <ErrorState message={error} />}
          {loading && !payload && <Loading what={t('blog.title').toLowerCase()} />}
          {payload && payload.articles.length === 0 && <Empty message={t('blog.empty')} />}
          {payload && payload.articles.length > 0 && (
            <div className="grid">
              {payload.articles.map((article) => (
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
          )}
        </div>
      </section>
    </>
  )
}
