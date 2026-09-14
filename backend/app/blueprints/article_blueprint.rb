class ArticleBlueprint < Blueprinter::Base
  identifier :id

  fields :slug, :category, :published_at

  field :title do |article, options|
    article.translated(:title, options[:locale])
  end

  field :excerpt do |article, options|
    article.translated(:excerpt, options[:locale])
  end

  field :available_locales do |article|
    article.translated_locales
  end

  field :cover_image_url do |article|
    article.cover_image_url(:card)
  end

  view :detail do
    field :body do |article, options|
      article.translated(:body, options[:locale])
    end

    field :cover_image_url do |article|
      article.cover_image_url(:hero)
    end
  end
end
