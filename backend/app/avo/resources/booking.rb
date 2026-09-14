class Avo::Resources::Booking < Avo::BaseResource
  self.title = :id
  self.includes = [ :user, :schedule ]

  self.search = {
    query: -> { query.ransack(payment_ref_cont: q, m: "or").result(distinct: false) },
    item: -> { { title: "Booking ##{record.id}", description: "#{record.user.name} · #{record.status}" } }
  }

  def actions
    action Avo::Actions::ConfirmBooking
    action Avo::Actions::CancelBooking
  end

  def fields
    field :id, as: :id
    field :user, as: :belongs_to, readonly: true
    field :schedule, as: :belongs_to, readonly: true
    field :participants, as: :number, readonly: true
    field :total_cents, as: :number, name: "Total (cents)", readonly: true
    field :status, as: :badge, options: { info: :pending, success: :confirmed, danger: :cancelled }
    field :notes, as: :textarea, readonly: true, hide_on: :index
    field :payment_ref, as: :text, readonly: true, hide_on: :index, help: "Unused until a payment gateway is added."
    field :created_at, as: :date_time, readonly: true

    # Every field above is read-only on purpose. Changing a booking's status has
    # to release or claim seats on the schedule, so it goes through the Confirm
    # and Cancel actions, which call the booking services.
  end
end
