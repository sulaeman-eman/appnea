module Api
  # Site-wide search across the two things people look for: what to learn, and
  # what to read. Trips are excluded on purpose — they are few and browsing the
  # list is faster than searching it.
  class SearchController < BaseController
    LIMIT = 10

    def index
      query = params[:q].to_s.strip

      if query.blank?
        render json: { query: "", courses: [], articles: [], total: 0 }
        return
      end

      courses = Course.published.search(query).limit(LIMIT)
      articles = Article.published.search(query).limit(LIMIT)

      render json: {
        query: query,
        courses: CourseBlueprint.render_as_hash(courses, locale: current_locale),
        articles: ArticleBlueprint.render_as_hash(articles, locale: current_locale),
        total: courses.size + articles.size
      }
    end
  end
end
