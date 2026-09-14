class Avo::Resources::Schedule < Avo::BaseResource
  self.title = :id
  self.includes = [ :course, :instructor ]
  self.default_sort_column = :start_date

  def fields
    field :id, as: :id
    field :course, as: :belongs_to, required: true
    field :instructor, as: :belongs_to

    field :start_date, as: :date, required: true
    field :end_date, as: :date, required: true
    field :capacity, as: :number, required: true
    field :status, as: :select, enum: ::Schedule.statuses, required: true

    # seats_taken is owned by Bookings::Create / Bookings::Cancel, which mutate it
    # under a row lock. Editing it by hand here would desync it from the bookings
    # and defeat the overbooking guard, so it is display-only.
    field :seats_taken, as: :number, readonly: true
    field :seats_available, as: :number, readonly: true, only_on: %i[index show]

    field :bookings, as: :has_many
  end
end
