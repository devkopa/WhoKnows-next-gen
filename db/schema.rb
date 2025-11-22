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

ActiveRecord::Schema[8.0].define(version: 2025_11_22_124015) do
  # These are extensions that must be enabled in order to support this database
  enable_extension "pg_catalog.plpgsql"

  create_table "_prisma_migrations", id: { type: :string, limit: 36 }, force: :cascade do |t|
    t.string "checksum", limit: 64, null: false
    t.timestamptz "finished_at"
    t.string "migration_name", limit: 255, null: false
    t.text "logs"
    t.timestamptz "rolled_back_at"
    t.timestamptz "started_at", default: -> { "now()" }, null: false
    t.integer "applied_steps_count", default: 0, null: false
  end

  create_table "pages", primary_key: "title", id: :text, force: :cascade do |t|
    t.text "url"
    t.text "language", default: "en"
    t.datetime "last_updated", precision: nil
    t.text "content"
    t.index ["url"], name: "idx_16409_sqlite_autoindex_pages_2", unique: true
  end

  create_table "users", force: :cascade do |t|
    t.text "username"
    t.text "email"
    t.string "password", limit: 255
    t.boolean "force_password_reset", default: false
    t.string "encrypted_password", default: "", null: false
    t.string "reset_password_token"
    t.datetime "reset_password_sent_at"
    t.datetime "remember_created_at"
    t.index ["email"], name: "idx_16416_sqlite_autoindex_users_2", unique: true
    t.index ["reset_password_token"], name: "index_users_on_reset_password_token", unique: true
    t.index ["username"], name: "idx_16416_sqlite_autoindex_users_1", unique: true
  end
end
