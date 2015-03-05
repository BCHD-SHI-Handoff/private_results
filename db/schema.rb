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

ActiveRecord::Schema.define(version: 20150305022315) do

  # These are extensions that must be enabled in order to support this database
  enable_extension "plpgsql"

  create_table "clinics", force: true do |t|
    t.string   "code",       null: false
    t.string   "name",       null: false
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "deliveries", force: true do |t|
    t.datetime "delivered_at",      null: false
    t.string   "delivery_method",   null: false
    t.string   "phone_number_used"
    t.text     "message",           null: false
  end

  create_table "deliveries_results", id: false, force: true do |t|
    t.integer "delivery_id"
    t.integer "result_id"
  end

  add_index "deliveries_results", ["delivery_id"], name: "index_deliveries_results_on_delivery_id", using: :btree
  add_index "deliveries_results", ["result_id"], name: "index_deliveries_results_on_result_id", using: :btree

  create_table "results", force: true do |t|
    t.integer  "visit_id",    null: false
    t.integer  "test_id",     null: false
    t.boolean  "positive"
    t.integer  "status_id"
    t.datetime "recorded_on", null: false
  end

  add_index "results", ["test_id"], name: "index_results_on_test_id", using: :btree
  add_index "results", ["visit_id"], name: "index_results_on_visit_id", using: :btree

  create_table "scripts", force: true do |t|
    t.string   "name"
    t.integer  "test_id"
    t.string   "language",   null: false
    t.integer  "status_id"
    t.text     "message",    null: false
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "scripts", ["status_id"], name: "index_scripts_on_status_id", using: :btree
  add_index "scripts", ["test_id"], name: "index_scripts_on_test_id", using: :btree

  create_table "statuses", force: true do |t|
    t.string "status", null: false
  end

  create_table "tests", force: true do |t|
    t.string "name", null: false
  end

  create_table "users", force: true do |t|
    t.string   "email",                  default: "", null: false
    t.string   "encrypted_password",     default: "", null: false
    t.string   "reset_password_token"
    t.datetime "reset_password_sent_at"
    t.datetime "remember_created_at"
    t.integer  "sign_in_count",          default: 0,  null: false
    t.datetime "current_sign_in_at"
    t.datetime "last_sign_in_at"
    t.inet     "current_sign_in_ip"
    t.inet     "last_sign_in_ip"
    t.string   "confirmation_token"
    t.datetime "confirmed_at"
    t.datetime "confirmation_sent_at"
    t.string   "unconfirmed_email"
    t.integer  "failed_attempts",        default: 0,  null: false
    t.string   "unlock_token"
    t.datetime "locked_at"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "users", ["confirmation_token"], name: "index_users_on_confirmation_token", unique: true, using: :btree
  add_index "users", ["email"], name: "index_users_on_email", unique: true, using: :btree
  add_index "users", ["reset_password_token"], name: "index_users_on_reset_password_token", unique: true, using: :btree
  add_index "users", ["unlock_token"], name: "index_users_on_unlock_token", unique: true, using: :btree

  create_table "visits", force: true do |t|
    t.string   "patient_number", null: false
    t.integer  "clinic_id",      null: false
    t.string   "username",       null: false
    t.string   "password",       null: false
    t.datetime "visited_on",     null: false
  end

  add_index "visits", ["clinic_id"], name: "index_visits_on_clinic_id", using: :btree

end
