# encoding: UTF-8
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

ActiveRecord::Schema.define(version: 20150301181749) do

  # These are extensions that must be enabled in order to support this database
  enable_extension "plpgsql"

  create_table "clinics", force: true do |t|
    t.string "code", null: false
    t.string "name", null: false
  end

  create_table "deliveries", force: true do |t|
    t.datetime "delivered_at",      null: false
    t.string   "delivery_method",   null: false
    t.string   "phone_number_used"
    t.text     "message",           null: false
  end

  create_table "results", force: true do |t|
    t.integer "visit_id",    null: false
    t.integer "test_id",     null: false
    t.boolean "positive"
    t.integer "status_id"
    t.integer "delivery_id"
  end

  add_index "results", ["delivery_id"], name: "index_results_on_delivery_id", using: :btree
  add_index "results", ["test_id"], name: "index_results_on_test_id", using: :btree
  add_index "results", ["visit_id"], name: "index_results_on_visit_id", using: :btree

  create_table "scripts", force: true do |t|
    t.string  "name"
    t.integer "test_id"
    t.string  "language",  null: false
    t.integer "status_id"
    t.text    "message",   null: false
  end

  add_index "scripts", ["status_id"], name: "index_scripts_on_status_id", using: :btree
  add_index "scripts", ["test_id"], name: "index_scripts_on_test_id", using: :btree

  create_table "statuses", force: true do |t|
    t.string "status", null: false
  end

  create_table "tests", force: true do |t|
    t.string "name", null: false
  end

  create_table "visits", force: true do |t|
    t.string   "patient_number", null: false
    t.integer  "clinic_id",      null: false
    t.string   "username",       null: false
    t.string   "password",       null: false
    t.datetime "visited_on",     null: false
  end

  add_index "visits", ["clinic_id"], name: "index_visits_on_clinic_id", using: :btree

end
