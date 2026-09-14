import { Link } from 'react-router'
import { useRouteState } from '../data'
import CourseCard from '../components/CourseCard'
import { ErrorState, Loading } from '../components/states'
import type { Article, Course } from '~/shared/types'
import { formatDate } from '~/shared/format'

interface HomeData {
  courses: Course[]
  articles: Article[]
}

export default function Home() {
  const { data, error, loading } = useRouteState()
  const home = data as HomeData | null

  return (
    <>
      <section className="hero">
        <div className="wrap">
          <h1>Learn to freedive in Bali</h1>
          <p>
            AIDA and Molchanovs certifications, coached depth camps, and guided fun dives —
            taught in small groups on the Amed wall and around Nusa Penida.
          </p>
          <Link to="/courses" className="button">Browse courses</Link>{' '}
          <Link to="/trips" className="button ghost">See trips</Link>
        </div>
      </section>

      {error && <ErrorState message={error} />}
      {loading && !home && <Loading what="courses" />}

      {home && (
        <>
          <section className="block">
            <div className="wrap">
              <div className="section-head">
                <h2>Start here</h2>
                <Link to="/courses">All courses →</Link>
              </div>
              <div className="grid">
                {home.courses.map((course) => <CourseCard key={course.id} course={course} />)}
              </div>
            </div>
          </section>

          {home.articles.length > 0 && (
            <section className="block tinted">
              <div className="wrap">
                <div className="section-head">
                  <h2>From the blog</h2>
                  <Link to="/blog">All articles →</Link>
                </div>
                <div className="grid">
                  {home.articles.map((article) => (
                    <Link key={article.id} to={`/blog/${article.slug}`} className="card">
                      <span className="tag">{article.category}</span>
                      <h3>{article.title}</h3>
                      <p>{article.excerpt}</p>
                      <div className="card-meta"><span>{formatDate(article.publishedAt)}</span></div>
                    </Link>
                  ))}
                </div>
              </div>
            </section>
          )}
        </>
      )}
    </>
  )
}
