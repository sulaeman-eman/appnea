# This file is auto-generated from the current state of the database. Instead
# of editing this file, please use the migrations feature of Active Record to
# incrementally modify your database, and then regenerate this schema definition.
#
# This file is the source Rails uses to define your schema when running `bin/rails
# db:schema:load`. When creating a new database, `bin/rails db:schema:load` tends to
# be faster and is potentially less error prone than running all of your
# migrations from scratch. Old migrations may fail to apply correctly if those
# migrations use external dependencies or application code.
#
# It's strongly recommended that you check this file into your version control system.

ActiveRecord::Schema[8.1].define(version: 2026_09_14_083314) do
  # These are extensions that must be enabled in order to support this database
  enable_extension "pg_catalog.plpgsql"

  create_table "active_storage_attachments", force: :cascade do |t|
    t.bigint "blob_id", null: false
    t.datetime "created_at", null: false
    t.string "name", null: false
    t.bigint "record_id", null: false
    t.string "record_type", null: false
    t.index ["blob_id"], name: "index_active_storage_attachments_on_blob_id"
    t.index ["record_type", "record_id", "name", "blob_id"], name: "index_active_storage_attachments_uniqueness", unique: true
  end

  create_table "active_storage_blobs", force: :cascade do |t|
    t.bigint "byte_size", null: false
    t.string "checksum"
    t.string "content_type"
    t.datetime "created_at", null: false
    t.string "filename", null: false
    t.string "key", null: false
    t.text "metadata"
    t.string "service_name", null: false
    t.index ["key"], name: "index_active_storage_blobs_on_key", unique: true
  end

  create_table "active_storage_variant_records", force: :cascade do |t|
    t.bigint "blob_id", null: false
    t.string "variation_digest", null: false
    t.index ["blob_id", "variation_digest"], name: "index_active_storage_variant_records_uniqueness", unique: true
  end

  create_table "articles", force: :cascade do |t|
    t.text "body", default: "", null: false
    t.string "category", default: "general", null: false
    t.datetime "created_at", null: false
    t.text "excerpt", default: "", null: false
    t.datetime "published_at"
    t.string "slug", null: false
    t.string "title", null: false
    t.datetime "updated_at", null: false
    t.index ["category"], name: "index_articles_on_category"
    t.index ["published_at"], name: "index_articles_on_published_at"
    t.index ["slug"], name: "index_articles_on_slug", unique: true
  end

  create_table "bookings", force: :cascade do |t|
    t.datetime "created_at", null: false
    t.text "notes", default: "", null: false
    t.integer "participants", default: 1, null: false
    t.string "payment_ref"
    t.bigint "schedule_id", null: false
    t.integer "status", default: 0, null: false
    t.integer "total_cents", default: 0, null: false
    t.datetime "updated_at", null: false
    t.bigint "user_id", null: false
    t.index ["schedule_id", "status"], name: "index_bookings_on_schedule_id_and_status"
    t.index ["schedule_id"], name: "index_bookings_on_schedule_id"
    t.index ["status"], name: "index_bookings_on_status"
    t.index ["user_id"], name: "index_bookings_on_user_id"
    t.check_constraint "participants > 0", name: "bookings_participants_positive"
    t.check_constraint "total_cents >= 0", name: "bookings_total_non_negative"
  end

  create_table "courses", force: :cascade do |t|
    t.integer "agency", default: 0, null: false
    t.datetime "created_at", null: false
    t.string "currency", default: "IDR", null: false
    t.integer "depth_target_m"
    t.text "description", default: "", null: false
    t.integer "duration_days", default: 1, null: false
    t.string "level", null: false
    t.integer "price_cents", default: 0, null: false
    t.boolean "published", default: false, null: false
    t.string "slug", null: false
    t.text "summary", default: "", null: false
    t.string "title", null: false
    t.datetime "updated_at", null: false
    t.index ["published"], name: "index_courses_on_published"
    t.index ["slug"], name: "index_courses_on_slug", unique: true
    t.check_constraint "duration_days > 0", name: "courses_duration_positive"
    t.check_constraint "price_cents >= 0", name: "courses_price_non_negative"
  end

  create_table "instructors", force: :cascade do |t|
    t.text "bio", default: "", null: false
    t.string "certifications", default: [], null: false, array: true
    t.datetime "created_at", null: false
    t.integer "display_order", default: 0, null: false
    t.string "name", null: false
    t.datetime "updated_at", null: false
    t.bigint "user_id"
    t.index ["display_order"], name: "index_instructors_on_display_order"
    t.index ["user_id"], name: "index_instructors_on_user_id", unique: true
  end

  create_table "schedules", force: :cascade do |t|
    t.integer "capacity", default: 4, null: false
    t.bigint "course_id", null: false
    t.datetime "created_at", null: false
    t.date "end_date", null: false
    t.bigint "instructor_id"
    t.integer "seats_taken", default: 0, null: false
    t.date "start_date", null: false
    t.integer "status", default: 0, null: false
    t.datetime "updated_at", null: false
    t.index ["course_id", "start_date"], name: "index_schedules_on_course_id_and_start_date"
    t.index ["course_id"], name: "index_schedules_on_course_id"
    t.index ["instructor_id"], name: "index_schedules_on_instructor_id"
    t.index ["start_date"], name: "index_schedules_on_start_date"
    t.check_constraint "capacity > 0", name: "schedules_capacity_positive"
    t.check_constraint "end_date >= start_date", name: "schedules_dates_ordered"
    t.check_constraint "seats_taken >= 0 AND seats_taken <= capacity", name: "schedules_seats_within_capacity"
  end

  create_table "trips", force: :cascade do |t|
    t.integer "capacity", default: 8, null: false
    t.datetime "created_at", null: false
    t.string "currency", default: "IDR", null: false
    t.text "description", default: "", null: false
    t.string "destination", null: false
    t.date "end_date", null: false
    t.integer "price_cents", default: 0, null: false
    t.boolean "published", default: false, null: false
    t.string "slug", null: false
    t.date "start_date", null: false
    t.text "summary", default: "", null: false
    t.string "title", null: false
    t.datetime "updated_at", null: false
    t.index ["slug"], name: "index_trips_on_slug", unique: true
    t.index ["start_date"], name: "index_trips_on_start_date"
    t.check_constraint "end_date >= start_date", name: "trips_dates_ordered"
    t.check_constraint "price_cents >= 0", name: "trips_price_non_negative"
  end

  create_table "users", force: :cascade do |t|
    t.datetime "created_at", null: false
    t.string "email", null: false
    t.string "name", null: false
    t.string "password_digest", null: false
    t.integer "role", default: 1, null: false
    t.datetime "updated_at", null: false
    t.index ["email"], name: "index_users_on_email", unique: true
  end

  add_foreign_key "active_storage_attachments", "active_storage_blobs", column: "blob_id"
  add_foreign_key "active_storage_variant_records", "active_storage_blobs", column: "blob_id"
  add_foreign_key "bookings", "schedules"
  add_foreign_key "bookings", "users"
  add_foreign_key "instructors", "users"
  add_foreign_key "schedules", "courses"
  add_foreign_key "schedules", "instructors"
end
