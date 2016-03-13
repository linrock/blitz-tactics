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

ActiveRecord::Schema.define(version: 20160313213221) do

  # These are extensions that must be enabled in order to support this database
  enable_extension "plpgsql"

  create_table "completed_rounds", force: :cascade do |t|
    t.integer  "level_attempt_id", null: false
    t.integer  "time_elapsed"
    t.integer  "errors_count"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "level_attempts", force: :cascade do |t|
    t.integer  "user_id",         null: false
    t.integer  "level_id",        null: false
    t.datetime "last_attempt_at"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "level_attempts", ["level_id"], name: "index_level_attempts_on_level_id", using: :btree
  add_index "level_attempts", ["user_id"], name: "index_level_attempts_on_user_id", using: :btree

  create_table "levels", force: :cascade do |t|
    t.string   "slug"
    t.integer  "next_level_id"
    t.string   "secret_key"
    t.integer  "puzzle_ids",    array: true
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "levels", ["secret_key"], name: "index_levels_on_secret_key", unique: true, using: :btree
  add_index "levels", ["slug"], name: "index_levels_on_slug", unique: true, using: :btree

  create_table "lichess_puzzles", force: :cascade do |t|
    t.integer  "puzzle_id",  null: false
    t.json     "data",       null: false
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "lichess_puzzles", ["puzzle_id"], name: "index_lichess_puzzles_on_puzzle_id", unique: true, using: :btree

  create_table "users", force: :cascade do |t|
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
    t.datetime "created_at",                          null: false
    t.datetime "updated_at",                          null: false
    t.string   "username"
    t.jsonb    "profile"
  end

  add_index "users", ["email"], name: "index_users_on_email", unique: true, using: :btree
  add_index "users", ["reset_password_token"], name: "index_users_on_reset_password_token", unique: true, using: :btree

end
