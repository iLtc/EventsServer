# This file is auto-generated from the current state of the database. Instead
# of editing this file, please use the migrations feature of Active Record to
# incrementally modify your database, and then regenerate this schema definition.
#
# Note that this schema.rb definition is the authoritative source for your
# database schema. If you need to create the application database on another
# system, you should be using db:schema:load, not running all the migrations
# from scratch. The latter is a flawed and unsustainable approach (the more migrations
# you'll amass, the slower it'll run and the greater likelihood for issues).
#
# It's strongly recommended that you check this file into your version control system.

ActiveRecord::Schema.define(version: 20180102122003) do

  create_table "event_categories", force: :cascade do |t|
    t.string "title"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "events", force: :cascade do |t|
    t.string "eid"
    t.string "title"
    t.text "url"
    t.text "location"
    t.text "description"
    t.text "photos"
    t.text "geo"
    t.text "categories"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.datetime "first_date"
    t.boolean "all_day"
    t.datetime "last_date"
    t.integer "views"
    t.boolean "verified", default: false
  end

  create_table "liked_events", force: :cascade do |t|
    t.integer "user_id"
    t.integer "event_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["event_id"], name: "index_liked_events_on_event_id"
    t.index ["user_id"], name: "index_liked_events_on_user_id"
  end

  create_table "logins", force: :cascade do |t|
    t.integer "user_id"
    t.string "pid"
    t.string "platform"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["user_id"], name: "index_logins_on_user_id"
  end

  create_table "owned_events", force: :cascade do |t|
    t.integer "user_id"
    t.integer "event_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["event_id"], name: "index_owned_events_on_event_id"
    t.index ["user_id"], name: "index_owned_events_on_user_id"
  end

  create_table "users", force: :cascade do |t|
    t.string "uid"
    t.string "name"
    t.string "pic_url"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

end
