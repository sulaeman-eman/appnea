class Avo::Resources::Article < Avo::BaseResource
  self.title = :title
  self.default_sort_column = :published_at
  self.default_sort_direction = :desc

  self.search = {
    query: -> { query.ransack(title_cont: q, category_cont: q, m: "or").result(distinct: false) },
    item: -> { { title: record.title, description: record.category } }
  }

  def fields
    field :id, as: :id
    field :title, as: :text, required: true
    field :slug, as: :text, help: "Leave blank on create and it is derived from the title."
    field :category, as: :text, required: true
    field :published_at, as: :date_time, help: "Blank means draft. The public API hides it until this time passes."

    field :excerpt, as: :textarea, hide_on: :index
    field :body, as: :textarea, hide_on: :index
    field :cover_image, as: :file, is_image: true, hide_on: :index

    field :translations, as: :code, language: "javascript", hide_on: :index,
      help: %(Per-locale overrides, e.g. {"id": {"title": "...", "body": "..."}}.)
  end
end
