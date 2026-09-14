class ArticleBlueprint < Blueprinter::Base
  identifier :id

  fields :slug, :title, :excerpt, :category, :published_at

  field :cover_image_url do |article|
    article.cover_image.attached? ? Rails.application.routes.url_helpers.rails_blob_path(article.cover_image, only_path: true) : nil
  end

  view :detail do
    field :body
  end
end
