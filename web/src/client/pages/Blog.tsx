import { Link } from 'react-router'
import { useRouteState } from '../data'
import { Empty, ErrorState, Loading } from '../components/states'
import type { Article, Meta } from '~/shared/types'
import { formatDate } from '~/shared/format'

export default function Blog() {
  const { data, error, loading } = useRouteState()
  const payload = data as { articles: Article[]; meta: Meta } | null

  return (
    <>
      <div className="page-head">
        <div className="wrap">
          <h1>Blog</h1>
          <p>Technique, safety, and travel notes from the Appnea team.</p>
        </div>
      </div>

      <section className="block">
        <div className="wrap">
          {error && <ErrorState message={error} />}
          {loading && !payload && <Loading what="articles" />}
          {payload && payload.articles.length === 0 && <Empty message="Nothing published yet." />}
          {payload && payload.articles.length > 0 && (
            <div className="grid">
              {payload.articles.map((article) => (
                <Link key={article.id} to={`/blog/${article.slug}`} className="card">
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
