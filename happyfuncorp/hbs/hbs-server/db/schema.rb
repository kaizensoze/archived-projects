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

ActiveRecord::Schema.define(version: 20140923045904) do

  # These are extensions that must be enabled in order to support this database
  enable_extension "plpgsql"

  create_table "active_admin_comments", force: true do |t|
    t.string   "namespace"
    t.text     "body"
    t.string   "resource_id",   null: false
    t.string   "resource_type", null: false
    t.integer  "author_id"
    t.string   "author_type"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "active_admin_comments", ["author_type", "author_id"], name: "index_active_admin_comments_on_author_type_and_author_id", using: :btree
  add_index "active_admin_comments", ["namespace"], name: "index_active_admin_comments_on_namespace", using: :btree
  add_index "active_admin_comments", ["resource_type", "resource_id"], name: "index_active_admin_comments_on_resource_type_and_resource_id", using: :btree

  create_table "admin_users", force: true do |t|
    t.string   "email",                  default: "", null: false
    t.string   "encrypted_password",     default: "", null: false
    t.string   "reset_password_token"
    t.datetime "reset_password_sent_at"
    t.datetime "remember_created_at"
    t.integer  "sign_in_count",          default: 0,  null: false
    t.datetime "current_sign_in_at"
    t.datetime "last_sign_in_at"
    t.string   "current_sign_in_ip"
    t.string   "last_sign_in_ip"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "admin_users", ["email"], name: "index_admin_users_on_email", unique: true, using: :btree
  add_index "admin_users", ["reset_password_token"], name: "index_admin_users_on_reset_password_token", unique: true, using: :btree

  create_table "announcements", force: true do |t|
    t.string   "summary",                      null: false
    t.string   "headline",                     null: false
    t.string   "image"
    t.text     "body",                         null: false
    t.string   "location"
    t.datetime "start_time"
    t.datetime "end_time"
    t.boolean  "has_button"
    t.string   "button_text"
    t.string   "button_link"
    t.boolean  "active",        default: true
    t.integer  "sort_order"
    t.integer  "admin_user_id"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "announcements", ["active"], name: "index_announcements_on_active", using: :btree
  add_index "announcements", ["sort_order"], name: "index_announcements_on_sort_order", using: :btree

  create_table "background_images", force: true do |t|
    t.string   "image",                     null: false
    t.boolean  "active",     default: true
    t.integer  "sort_order"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "background_images", ["active"], name: "index_background_images_on_active", using: :btree
  add_index "background_images", ["sort_order"], name: "index_background_images_on_sort_order", using: :btree

  create_table "did_you_know_items", force: true do |t|
    t.string   "title"
    t.string   "website"
    t.string   "email"
    t.string   "phone_number"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "did_you_know_subject_id"
    t.integer  "sort_order"
  end

  add_index "did_you_know_items", ["sort_order"], name: "index_did_you_know_items_on_sort_order", using: :btree

  create_table "did_you_know_subjects", force: true do |t|
    t.string   "subject",    null: false
    t.integer  "sort_order"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "did_you_know_subjects", ["sort_order"], name: "index_did_you_know_subjects_on_sort_order", using: :btree
  add_index "did_you_know_subjects", ["subject"], name: "index_did_you_know_subjects_on_subject", unique: true, using: :btree

  create_table "gym_schedules", force: true do |t|
    t.date     "date",          null: false
    t.string   "summary",       null: false
    t.text     "body",          null: false
    t.integer  "admin_user_id"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "gym_schedules", ["date"], name: "index_gym_schedules_on_date", unique: true, using: :btree

  create_table "help_now_items", force: true do |t|
    t.string   "title"
    t.string   "body"
    t.string   "phone_number"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "sort_order"
  end

  add_index "help_now_items", ["sort_order"], name: "index_help_now_items_on_sort_order", using: :btree

  create_table "menus", force: true do |t|
    t.date     "date",          null: false
    t.string   "summary",       null: false
    t.text     "body",          null: false
    t.integer  "admin_user_id"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "menus", ["date"], name: "index_menus_on_date", unique: true, using: :btree

  create_table "polls", force: true do |t|
    t.string   "active_id"
    t.datetime "created_at"
    t.datetime "updated_at"
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
    t.string   "current_sign_in_ip"
    t.string   "last_sign_in_ip"
    t.string   "confirmation_token"
    t.datetime "confirmed_at"
    t.datetime "confirmation_sent_at"
    t.string   "unconfirmed_email"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string   "pending_device_id"
    t.string   "auth_token"
    t.string   "first_name"
    t.string   "last_name"
    t.string   "type"
    t.string   "section"
    t.string   "class_year"
    t.string   "confirmed_device_id"
  end

  add_index "users", ["auth_token"], name: "index_users_on_auth_token", using: :btree
  add_index "users", ["confirmation_token"], name: "index_users_on_confirmation_token", unique: true, using: :btree
  add_index "users", ["confirmed_device_id"], name: "index_users_on_confirmed_device_id", using: :btree
  add_index "users", ["email"], name: "index_users_on_email", unique: true, using: :btree
  add_index "users", ["pending_device_id"], name: "index_users_on_pending_device_id", using: :btree
  add_index "users", ["reset_password_token"], name: "index_users_on_reset_password_token", unique: true, using: :btree

  create_table "who_to_call_items", force: true do |t|
    t.string   "title"
    t.string   "name"
    t.string   "phone_number"
    t.string   "email"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "sort_order"
    t.integer  "who_to_call_subject_id"
  end

  add_index "who_to_call_items", ["sort_order"], name: "index_who_to_call_items_on_sort_order", using: :btree

  create_table "who_to_call_subjects", force: true do |t|
    t.string   "subject",    null: false
    t.integer  "sort_order"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "who_to_call_subjects", ["sort_order"], name: "index_who_to_call_subjects_on_sort_order", using: :btree
  add_index "who_to_call_subjects", ["subject"], name: "index_who_to_call_subjects_on_subject", unique: true, using: :btree

end
