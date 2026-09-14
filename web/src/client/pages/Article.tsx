import { useRouteState } from '../data'
import { ErrorState, Loading } from '../components/states'
import type { ArticleDetail } from '~/shared/types'
import { formatDate } from '~/shared/format'

export default function ArticlePage() {
  const { data, error, loading } = useRouteState()
  const article = (data as { article: ArticleDetail } | null)?.article

  if (error) return <ErrorState message={error} />
  if (loading || !article) return <Loading what="article" />

  return (
    <>
      <div className="page-head">
        <div className="wrap">
          <span className="tag">{article.category}</span>
          <h1>{article.title}</h1>
          <p>{formatDate(article.publishedAt)}</p>
        </div>
      </div>

      <div className="wrap detail-layout">
        <div className="prose">
          {article.body.split('\n').filter(Boolean).map((paragraph, index) => (
            <p key={index}>{paragraph}</p>
          ))}
        </div>
      </div>
    </>
  )
}
