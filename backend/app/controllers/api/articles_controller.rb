module Api
  class ArticlesController < BaseController
    def index
      scope = Article.published
      scope = scope.where(category: params[:category]) if params[:category].present?
      scope = scope.search(params[:q]) if params[:q].present?
      articles = paginate(scope)

      render json: {
        articles: ArticleBlueprint.render_as_hash(articles, locale: current_locale),
        meta: meta_for(scope, articles)
      }
    end

    def show
      # Scoped to published so a draft is a 404, not a preview leak.
      article = Article.published.find_by!(slug: params[:slug])
      render json: { article: ArticleBlueprint.render_as_hash(article, view: :detail, locale: current_locale) }
    end
  end
end
