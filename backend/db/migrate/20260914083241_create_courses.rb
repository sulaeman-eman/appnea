class CreateCourses < ActiveRecord::Migration[8.1]
  def change
    create_table :courses do |t|
      t.string :slug, null: false
      t.string :title, null: false
      # 0 aida, 1 ssi, 2 molchanovs — see Course#agency
      t.integer :agency, null: false, default: 0
      t.string :level, null: false
      t.integer :depth_target_m
      t.integer :duration_days, null: false, default: 1
      t.integer :price_cents, null: false, default: 0
      t.string :currency, null: false, default: "IDR"
      t.text :summary, null: false, default: ""
      t.text :description, null: false, default: ""
      t.boolean :published, null: false, default: false

      t.timestamps
    end

    add_index :courses, :slug, unique: true
    add_index :courses, :published

    add_check_constraint :courses, "price_cents >= 0", name: "courses_price_non_negative"
    add_check_constraint :courses, "duration_days > 0", name: "courses_duration_positive"
  end
end
