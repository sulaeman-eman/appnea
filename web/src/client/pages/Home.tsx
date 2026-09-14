import { Link } from 'react-router'
import { useRouteState } from '../data'
import { useLocale } from '../locale'
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
  const { t } = useLocale()
  const home = data as HomeData | null

  return (
    <>
      <section className="hero">
        <div className="wrap">
          <h1>{t('home.title')}</h1>
          <p>{t('home.lead')}</p>
          <Link to="/courses" className="button">{t('home.browse')}</Link>{' '}
          <Link to="/trips" className="button ghost">{t('home.seeTrips')}</Link>
        </div>
      </section>

      {error && <ErrorState message={error} />}
      {loading && !home && <Loading what={t('nav.courses').toLowerCase()} />}

      {home && (
        <>
          <section className="block">
            <div className="wrap">
              <div className="section-head">
                <h2>{t('home.startHere')}</h2>
                <Link to="/courses">{t('home.allCourses')}</Link>
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
                  <h2>{t('home.fromBlog')}</h2>
                  <Link to="/blog">{t('home.allArticles')}</Link>
                </div>
                <div className="grid">
                  {home.articles.map((article) => (
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
              </div>
            </section>
          )}
        </>
      )}
    </>
  )
}
