class CreateTrips < ActiveRecord::Migration[8.1]
  def change
    create_table :trips do |t|
      t.string :slug, null: false
      t.string :title, null: false
      t.string :destination, null: false
      t.date :start_date, null: false
      t.date :end_date, null: false
      t.integer :capacity, null: false, default: 8
      t.integer :price_cents, null: false, default: 0
      t.string :currency, null: false, default: "IDR"
      t.text :summary, null: false, default: ""
      t.text :description, null: false, default: ""
      t.boolean :published, null: false, default: false

      t.timestamps
    end

    add_index :trips, :slug, unique: true
    add_index :trips, :start_date

    add_check_constraint :trips, "price_cents >= 0", name: "trips_price_non_negative"
    add_check_constraint :trips, "end_date >= start_date", name: "trips_dates_ordered"
  end
end
