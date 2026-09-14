class Avo::Resources::Instructor < Avo::BaseResource
  self.title = :name
  self.includes = [ :user ]
  self.default_sort_column = :display_order
  self.default_sort_direction = :asc

  self.search = {
    query: -> { query.ransack(name_cont: q, m: "or").result(distinct: false) },
    item: -> { { title: record.name, description: record.certifications.join(", ") } }
  }

  def fields
    field :id, as: :id
    field :name, as: :text, required: true
    field :display_order, as: :number, help: "Lower numbers appear first on the site."
    field :user, as: :belongs_to, help: "Optional — only needed if this instructor logs in."
    field :certifications, as: :tags, help: "e.g. AIDA Instructor, SSI Level 2"
    field :bio, as: :textarea, hide_on: :index
    field :photo, as: :file, is_image: true, hide_on: :index

    field :schedules, as: :has_many
  end
end
