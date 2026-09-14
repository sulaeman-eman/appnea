class Avo::Resources::Course < Avo::BaseResource
  self.title = :title
  self.includes = [ :schedules ]
  self.search = {
    query: -> { query.ransack(title_cont: q, slug_cont: q, m: "or").result(distinct: false) },
    item: -> { { title: record.title, description: "#{record.agency.upcase} · #{record.level}" } }
  }

  def fields
    field :id, as: :id
    field :title, as: :text, required: true
    field :slug, as: :text,
      help: "Leave blank on create and it is derived from the title."
    field :agency, as: :select, enum: ::Course.agencies, required: true
    field :level, as: :text, required: true, help: "e.g. Level 1, Advanced, Instructor"
    field :depth_target_m, as: :number, name: "Depth target (m)"
    field :duration_days, as: :number, required: true
    field :price_cents, as: :number, name: "Price (cents)", required: true
    field :currency, as: :text
    field :published, as: :boolean

    field :summary, as: :textarea, hide_on: :index
    field :description, as: :textarea, hide_on: :index
    field :cover_image, as: :file, is_image: true, hide_on: :index

    field :translations, as: :code, language: "javascript", hide_on: :index,
      help: %(Per-locale overrides, e.g. {"id": {"title": "...", "summary": "..."}}. Anything omitted falls back to the English column above.)

    field :schedules, as: :has_many
  end
end
