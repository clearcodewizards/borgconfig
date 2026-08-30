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

ActiveRecord::Schema[8.0].define(version: 2026_08_30_100902) do
  create_table "cube_tags", force: :cascade do |t|
    t.integer "cube_id", null: false
    t.integer "tag_id", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["cube_id"], name: "index_cube_tags_on_cube_id"
    t.index ["tag_id"], name: "index_cube_tags_on_tag_id"
  end

  create_table "cubes", force: :cascade do |t|
    t.string "api_token", null: false
    t.string "name", null: false
    t.integer "status", default: 0, null: false
    t.boolean "registered", default: false, null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["api_token"], name: "index_cubes_on_api_token", unique: true
  end

  create_table "directives", force: :cascade do |t|
    t.integer "cube_id", null: false
    t.integer "depends_on_id"
    t.integer "status", default: 0, null: false
    t.string "filename", null: false
    t.text "arguments"
    t.text "output"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["cube_id"], name: "index_directives_on_cube_id"
    t.index ["depends_on_id"], name: "index_directives_on_depends_on_id"
  end

  create_table "sessions", force: :cascade do |t|
    t.integer "user_id", null: false
    t.string "ip_address"
    t.string "user_agent"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["user_id"], name: "index_sessions_on_user_id"
  end

  create_table "tags", force: :cascade do |t|
    t.string "name", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["name"], name: "index_tags_on_name", unique: true
  end

  create_table "users", force: :cascade do |t|
    t.string "email_address", null: false
    t.string "password_digest", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.integer "role", default: 0, null: false
    t.string "name", default: "", null: false
    t.string "api_token"
    t.index ["api_token"], name: "index_users_on_api_token", unique: true
    t.index ["email_address"], name: "index_users_on_email_address", unique: true
  end

  add_foreign_key "cube_tags", "cubes"
  add_foreign_key "cube_tags", "tags"
  add_foreign_key "directives", "cubes"
  add_foreign_key "directives", "directives", column: "depends_on_id"
  add_foreign_key "sessions", "users"
end
