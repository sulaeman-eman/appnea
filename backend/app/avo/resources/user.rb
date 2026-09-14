class Avo::Resources::User < Avo::BaseResource
  self.title = :name
  self.search = {
    query: -> { query.ransack(name_cont: q, email_cont: q, m: "or").result(distinct: false) },
    item: -> { { title: record.name, description: "#{record.email} · #{record.role}" } }
  }

  def fields
    field :id, as: :id
    field :name, as: :text, required: true
    field :email, as: :text, required: true
    field :role, as: :select, enum: ::User.roles, required: true

    # has_secure_password writes password_digest; never expose the digest itself.
    field :password, as: :password, only_on: :forms,
      help: "Minimum 8 characters. Leave blank to keep the current password."
    field :password_confirmation, as: :password, only_on: :forms

    field :bookings, as: :has_many
  end
end
