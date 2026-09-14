class CreateSchedules < ActiveRecord::Migration[8.1]
  def change
    create_table :schedules do |t|
      t.references :course, null: false, foreign_key: true
      t.references :instructor, null: true, foreign_key: true
      t.date :start_date, null: false
      t.date :end_date, null: false
      t.integer :capacity, null: false, default: 4
      t.integer :seats_taken, null: false, default: 0
      # 0 open, 1 full, 2 cancelled, 3 done — see Schedule#status
      t.integer :status, null: false, default: 0

      t.timestamps
    end

    add_index :schedules, :start_date
    add_index :schedules, %i[course_id start_date]

    # The booking service holds a row lock while it increments seats_taken, but
    # this constraint is the thing that actually makes overbooking impossible —
    # any path that bypasses the service still cannot push seats past capacity.
    add_check_constraint :schedules,
      "seats_taken >= 0 AND seats_taken <= capacity",
      name: "schedules_seats_within_capacity"
    add_check_constraint :schedules, "capacity > 0", name: "schedules_capacity_positive"
    add_check_constraint :schedules, "end_date >= start_date", name: "schedules_dates_ordered"
  end
end
