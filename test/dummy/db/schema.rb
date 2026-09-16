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

ActiveRecord::Schema[8.1].define(version: 2026_09_14_120005) do
  create_table "cities", force: :cascade do |t|
    t.datetime "created_at", null: false
    t.string "fips", limit: 5, null: false
    t.string "google_place_id"
    t.string "name", null: false
    t.integer "state_id", null: false
    t.datetime "updated_at", null: false
    t.index ["name"], name: "index_cities_on_name"
    t.index ["state_id", "fips"], name: "index_cities_on_state_id_and_fips", unique: true
  end

  create_table "city_counties", id: false, force: :cascade do |t|
    t.integer "city_id", null: false
    t.integer "county_id", null: false
    t.index ["city_id", "county_id"], name: "index_city_counties_on_city_id_and_county_id", unique: true
    t.index ["county_id"], name: "index_city_counties_on_county_id"
  end

  create_table "counties", force: :cascade do |t|
    t.datetime "created_at", null: false
    t.string "fips", limit: 5, null: false
    t.string "google_place_id"
    t.string "name", null: false
    t.integer "state_id", null: false
    t.datetime "updated_at", null: false
    t.integer "zips_count", default: 0, null: false
    t.index ["fips"], name: "index_counties_on_fips", unique: true
    t.index ["name"], name: "index_counties_on_name"
    t.index ["state_id"], name: "index_counties_on_state_id"
  end

  create_table "states", force: :cascade do |t|
    t.string "code", limit: 2, null: false
    t.integer "counties_count", default: 0, null: false
    t.datetime "created_at", null: false
    t.string "fips", limit: 2, null: false
    t.string "google_place_id"
    t.string "name", null: false
    t.datetime "updated_at", null: false
    t.index ["code"], name: "index_states_on_code", unique: true
    t.index ["fips"], name: "index_states_on_fips", unique: true
    t.index ["name"], name: "index_states_on_name", unique: true
  end

  create_table "zips", force: :cascade do |t|
    t.string "city", null: false
    t.string "code", limit: 5, null: false
    t.integer "county_id", null: false
    t.datetime "created_at", null: false
    t.string "google_place_id"
    t.string "time_zone", null: false
    t.datetime "updated_at", null: false
    t.index ["city"], name: "index_zips_on_city"
    t.index ["code"], name: "index_zips_on_code", unique: true
    t.index ["county_id"], name: "index_zips_on_county_id"
  end

  add_foreign_key "cities", "states"
  add_foreign_key "city_counties", "cities"
  add_foreign_key "city_counties", "counties"
  add_foreign_key "counties", "states"
  add_foreign_key "zips", "counties"
end
