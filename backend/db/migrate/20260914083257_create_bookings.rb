class CreateBookings < ActiveRecord::Migration[8.1]
  def change
    create_table :bookings do |t|
      t.references :user, null: false, foreign_key: true
      t.references :schedule, null: false, foreign_key: true
      t.integer :participants, null: false, default: 1
      # 0 pending, 1 confirmed, 2 cancelled — see Booking#status
      t.integer :status, null: false, default: 0
      t.integer :total_cents, null: false, default: 0
      t.text :notes, null: false, default: ""
      # Unused in MVP. Present so adding a payment gateway later is an
      # integration rather than a migration of live rows.
      t.string :payment_ref

      t.timestamps
    end

    add_index :bookings, :status
    add_index :bookings, %i[schedule_id status]

    add_check_constraint :bookings, "participants > 0", name: "bookings_participants_positive"
    add_check_constraint :bookings, "total_cents >= 0", name: "bookings_total_non_negative"
  end
end
