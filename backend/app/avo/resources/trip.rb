class Avo::Resources::Trip < Avo::BaseResource
  self.title = :title
  self.default_sort_column = :start_date

  self.search = {
    query: -> { query.ransack(title_cont: q, destination_cont: q, m: "or").result(distinct: false) },
    item: -> { { title: record.title, description: "#{record.destination} · #{record.start_date}" } }
  }

  def fields
    field :id, as: :id
    field :title, as: :text, required: true
    field :slug, as: :text, help: "Leave blank on create and it is derived from the title."
    field :destination, as: :text, required: true
    field :start_date, as: :date, required: true
    field :end_date, as: :date, required: true
    field :capacity, as: :number, required: true
    field :price_cents, as: :number, name: "Price (cents)", required: true
    field :currency, as: :text
    field :published, as: :boolean

    field :summary, as: :textarea, hide_on: :index
    field :description, as: :textarea, hide_on: :index
    field :cover_image, as: :file, is_image: true, hide_on: :index

    field :translations, as: :code, language: "javascript", hide_on: :index,
      help: %(Per-locale overrides, e.g. {"id": {"title": "...", "summary": "..."}}.)
  end
end
