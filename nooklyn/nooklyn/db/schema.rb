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

ActiveRecord::Schema.define(version: 20160216020905) do

  # These are extensions that must be enabled in order to support this database
  enable_extension "plpgsql"
  enable_extension "pg_stat_statements"

  create_table "agents", force: :cascade do |t|
    t.string   "first_name",                   limit: 255
    t.string   "last_name",                    limit: 255
    t.string   "phone",                        limit: 255
    t.string   "email",                        limit: 255
    t.boolean  "admin",                                    default: false
    t.datetime "created_at",                                               null: false
    t.datetime "updated_at",                                               null: false
    t.string   "encrypted_password",           limit: 255, default: "",    null: false
    t.string   "reset_password_token",         limit: 255
    t.datetime "reset_password_sent_at"
    t.datetime "remember_created_at"
    t.integer  "sign_in_count",                            default: 0
    t.datetime "current_sign_in_at"
    t.datetime "last_sign_in_at"
    t.string   "current_sign_in_ip",           limit: 255
    t.string   "last_sign_in_ip",              limit: 255
    t.boolean  "super_admin",                              default: false
    t.boolean  "employee",                                 default: false
    t.boolean  "employer",                                 default: false
    t.boolean  "on_probation",                             default: false
    t.string   "provider",                     limit: 255
    t.string   "uid",                          limit: 255
    t.string   "oauth_token",                  limit: 255
    t.datetime "oauth_expires_at"
    t.string   "image",                        limit: 255
    t.string   "facebook_url",                 limit: 255
    t.string   "gender",                       limit: 255
    t.string   "profile_picture_file_name",    limit: 255
    t.string   "profile_picture_content_type", limit: 255
    t.integer  "profile_picture_file_size"
    t.datetime "profile_picture_updated_at"
    t.boolean  "private_profile",                          default: false
    t.string   "confirmation_token"
    t.datetime "confirmed_at"
    t.datetime "confirmation_sent_at"
    t.boolean  "suspended",                                default: false
    t.string   "device_token"
    t.boolean  "on_vacation",                              default: false
    t.boolean  "read_only_admin",                          default: false
    t.integer  "region_id"
    t.boolean  "sms_notifications",                        default: true
    t.string   "slug"
    t.boolean  "email_notifications",                      default: true
  end

  add_index "agents", ["confirmation_token"], name: "index_agents_on_confirmation_token", unique: true, using: :btree
  add_index "agents", ["email"], name: "index_agents_on_email", unique: true, using: :btree
  add_index "agents", ["reset_password_token"], name: "index_agents_on_reset_password_token", unique: true, using: :btree

  create_table "api_keys", force: :cascade do |t|
    t.integer  "agent_id"
    t.string   "token",      limit: 255
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "api_keys", ["agent_id"], name: "index_api_keys_on_agent_id", using: :btree
  add_index "api_keys", ["token"], name: "index_api_keys_on_token", unique: true, using: :btree

  create_table "check_request_documents", force: :cascade do |t|
    t.datetime "created_at",              null: false
    t.datetime "updated_at",              null: false
    t.string   "attachment_file_name"
    t.string   "attachment_content_type"
    t.integer  "attachment_file_size"
    t.datetime "attachment_updated_at"
    t.integer  "check_request_id"
  end

  create_table "check_request_types", force: :cascade do |t|
    t.string   "name"
    t.boolean  "active"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "check_requests", force: :cascade do |t|
    t.string   "name"
    t.string   "apartment_address"
    t.string   "unit"
    t.float    "amount"
    t.datetime "check_date"
    t.boolean  "check_type"
    t.boolean  "approved",              default: false
    t.text     "notes"
    t.integer  "agent_id"
    t.datetime "created_at",                            null: false
    t.datetime "updated_at",                            null: false
    t.integer  "check_request_type_id"
    t.boolean  "rejected",              default: false
    t.boolean  "verified",              default: false
  end

  create_table "conversation_messages", force: :cascade do |t|
    t.integer  "agent_id"
    t.integer  "conversation_id"
    t.string   "ip_address"
    t.string   "user_agent"
    t.text     "message"
    t.datetime "created_at",      null: false
    t.datetime "updated_at",      null: false
  end

  add_index "conversation_messages", ["agent_id"], name: "index_conversation_messages_on_agent_id", using: :btree
  add_index "conversation_messages", ["conversation_id"], name: "index_conversation_messages_on_conversation_id", using: :btree

  create_table "conversation_participants", force: :cascade do |t|
    t.integer  "agent_id"
    t.integer  "conversation_id"
    t.datetime "created_at",                      null: false
    t.datetime "updated_at",                      null: false
    t.boolean  "unread_messages", default: false
    t.datetime "archived_at"
  end

  add_index "conversation_participants", ["agent_id"], name: "index_conversation_participants_on_agent_id", using: :btree
  add_index "conversation_participants", ["conversation_id"], name: "index_conversation_participants_on_conversation_id", using: :btree

  create_table "conversations", force: :cascade do |t|
    t.datetime "created_at",               null: false
    t.datetime "updated_at",               null: false
    t.string   "context_url", default: ""
  end

  create_table "deposit_attachments", force: :cascade do |t|
    t.integer  "agent_id"
    t.integer  "deposit_id"
    t.datetime "created_at",              null: false
    t.datetime "updated_at",              null: false
    t.string   "attachment_file_name"
    t.string   "attachment_content_type"
    t.integer  "attachment_file_size"
    t.datetime "attachment_updated_at"
  end

  create_table "deposit_clients", force: :cascade do |t|
    t.string   "name"
    t.boolean  "guarantor"
    t.integer  "deposit_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.integer  "creator_id"
  end

  create_table "deposit_statuses", force: :cascade do |t|
    t.string   "name"
    t.text     "description"
    t.boolean  "active"
    t.datetime "created_at",  null: false
    t.datetime "updated_at",  null: false
  end

  create_table "deposit_transactions", force: :cascade do |t|
    t.float    "amount"
    t.string   "deposit_transaction_type"
    t.string   "client_name"
    t.integer  "office_id"
    t.integer  "deposit_id"
    t.text     "notes"
    t.datetime "created_at",               null: false
    t.datetime "updated_at",               null: false
    t.integer  "creator_id"
  end

  create_table "deposits", force: :cascade do |t|
    t.string   "address"
    t.string   "unit"
    t.integer  "listing_agent_id"
    t.integer  "sales_agent_id"
    t.integer  "other_sales_agent_id"
    t.float    "apartment_price"
    t.float    "offer_price"
    t.datetime "when"
    t.string   "full_address"
    t.datetime "created_at",                           null: false
    t.datetime "updated_at",                           null: false
    t.string   "length_of_lease"
    t.string   "landlord_llc"
    t.integer  "deposit_status_id"
    t.integer  "office_id"
    t.boolean  "refund",               default: false
    t.text     "description"
    t.string   "credit_check"
    t.integer  "creator_id"
    t.integer  "training_agent_id"
    t.float    "owner_pays"
    t.float    "total_broker_fee"
  end

  create_table "feedbacks", force: :cascade do |t|
    t.string   "name",       limit: 255
    t.string   "email",      limit: 255
    t.text     "message"
    t.datetime "created_at",             null: false
    t.datetime "updated_at",             null: false
  end

  create_table "guide_stories", force: :cascade do |t|
    t.integer  "guide_id"
    t.string   "url"
    t.string   "title"
    t.text     "description"
    t.boolean  "featured"
    t.datetime "created_at",         null: false
    t.datetime "updated_at",         null: false
    t.string   "image_file_name"
    t.string   "image_content_type"
    t.integer  "image_file_size"
    t.datetime "image_updated_at"
    t.integer  "neighborhood_id"
  end

  create_table "guide_story_photos", force: :cascade do |t|
    t.string   "caption"
    t.integer  "agent_id"
    t.integer  "guide_story_id"
    t.datetime "created_at",         null: false
    t.datetime "updated_at",         null: false
    t.string   "image_file_name"
    t.string   "image_content_type"
    t.integer  "image_file_size"
    t.datetime "image_updated_at"
  end

  create_table "guides", force: :cascade do |t|
    t.integer  "neighborhood_id"
    t.string   "title"
    t.text     "description"
    t.text     "pull_quote"
    t.string   "pull_quote_author"
    t.datetime "created_at",                               null: false
    t.datetime "updated_at",                               null: false
    t.boolean  "featured",                 default: false
    t.string   "cover_image_file_name"
    t.string   "cover_image_content_type"
    t.integer  "cover_image_file_size"
    t.datetime "cover_image_updated_at"
    t.string   "slug"
  end

  create_table "hearts", force: :cascade do |t|
    t.integer  "agent_id"
    t.integer  "listing_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "job_applications", force: :cascade do |t|
    t.string   "full_name",           limit: 255
    t.string   "email",               limit: 255
    t.string   "phone",               limit: 255
    t.string   "current_company",     limit: 255
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string   "resume_file_name",    limit: 255
    t.string   "resume_content_type", limit: 255
    t.integer  "resume_file_size"
    t.datetime "resume_updated_at"
    t.string   "position",            limit: 255
    t.integer  "agent_id"
  end

  create_table "key_checkouts", force: :cascade do |t|
    t.text     "message"
    t.integer  "agent_id"
    t.boolean  "returned",   default: false
    t.datetime "created_at",                 null: false
    t.datetime "updated_at",                 null: false
    t.integer  "office_id"
  end

  create_table "lead_updates", force: :cascade do |t|
    t.text     "message"
    t.integer  "lead_id"
    t.string   "ip_address", limit: 255
    t.string   "user_agent", limit: 255
    t.integer  "agent_id"
    t.datetime "created_at",             null: false
    t.datetime "updated_at",             null: false
  end

  create_table "leads", force: :cascade do |t|
    t.string   "full_name",   limit: 255
    t.string   "phone",       limit: 255
    t.string   "email",       limit: 255
    t.date     "move_in"
    t.boolean  "pets"
    t.float    "min_price"
    t.float    "max_price"
    t.text     "comments"
    t.datetime "contacted"
    t.integer  "agent_id"
    t.boolean  "is_landlord"
    t.datetime "created_at",              null: false
    t.datetime "updated_at",              null: false
  end

  create_table "listing_ignores", force: :cascade do |t|
    t.integer  "agent_id"
    t.integer  "listing_id"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "listing_status_changes", force: :cascade do |t|
    t.integer  "listing_id"
    t.integer  "agent_id"
    t.integer  "status"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  add_index "listing_status_changes", ["agent_id"], name: "index_listing_status_changes_on_agent_id", using: :btree
  add_index "listing_status_changes", ["listing_id"], name: "index_listing_status_changes_on_listing_id", using: :btree

  create_table "listings", force: :cascade do |t|
    t.string   "title",              limit: 255
    t.text     "description"
    t.string   "address",            limit: 255
    t.date     "date_available"
    t.float    "price"
    t.float    "bedrooms"
    t.float    "bathrooms"
    t.boolean  "pets"
    t.string   "fee",                limit: 255
    t.string   "subway_line",        limit: 255
    t.string   "station",            limit: 255
    t.text     "amenities"
    t.integer  "sales_agent_id"
    t.integer  "listing_agent_id"
    t.string   "term",               limit: 255
    t.boolean  "residential"
    t.boolean  "rental",                         default: true
    t.datetime "created_at",                                                                                           null: false
    t.datetime "updated_at",                                                                                           null: false
    t.float    "latitude"
    t.float    "longitude"
    t.boolean  "featured",                       default: false
    t.integer  "neighborhood_id"
    t.string   "apartment",          limit: 255
    t.text     "access"
    t.integer  "square_feet"
    t.string   "landlord_contact",   limit: 255
    t.string   "status",             limit: 255, default: "Available"
    t.boolean  "exclusive",                      default: false
    t.string   "cross_streets",      limit: 255
    t.string   "utilities",          limit: 255
    t.integer  "hearts_count",                   default: 0
    t.integer  "photos_count",                   default: 0
    t.string   "primaryphoto",                   default: "https://s3.amazonaws.com/nooklyn-pro/square/1/forent.jpeg"
    t.boolean  "move_in_cost"
    t.float    "owner_pays"
    t.string   "image_file_name",    limit: 255
    t.string   "image_content_type", limit: 255
    t.integer  "image_file_size"
    t.datetime "image_updated_at"
    t.boolean  "private",                        default: false
    t.integer  "office_id"
    t.string   "full_address"
    t.string   "zip"
    t.boolean  "convertible",                    default: false
    t.string   "landlord_llc"
  end

  add_index "listings", ["primaryphoto"], name: "index_listings_on_primaryphoto", using: :btree
  add_index "listings", ["status"], name: "index_listings_on_status", using: :btree

  create_table "listings_collection_memberships", force: :cascade do |t|
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "listing_id"
    t.integer  "listings_collection_id"
  end

  add_index "listings_collection_memberships", ["listing_id", "listings_collection_id"], name: "index_listings_collection_memberships", unique: true, using: :btree

  create_table "listings_collections", force: :cascade do |t|
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "agent_id"
    t.string   "name",                        null: false
    t.boolean  "private",     default: false
    t.text     "description"
    t.boolean  "featured",    default: false
    t.string   "slug"
  end

  add_index "listings_collections", ["slug"], name: "index_listings_collections_on_slug", unique: true, using: :btree

  create_table "location_categories", force: :cascade do |t|
    t.string   "name",               limit: 255
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string   "image_file_name",    limit: 255
    t.string   "image_content_type", limit: 255
    t.integer  "image_file_size"
    t.datetime "image_updated_at"
    t.boolean  "featured",                       default: false
    t.string   "slug"
  end

  create_table "location_likes", force: :cascade do |t|
    t.integer  "agent_id"
    t.integer  "location_id"
    t.datetime "created_at",  null: false
    t.datetime "updated_at",  null: false
  end

  create_table "location_photos", force: :cascade do |t|
    t.datetime "created_at",         null: false
    t.datetime "updated_at",         null: false
    t.string   "image_file_name"
    t.string   "image_content_type"
    t.integer  "image_file_size"
    t.datetime "image_updated_at"
    t.integer  "location_id"
    t.text     "caption"
  end

  create_table "locations", force: :cascade do |t|
    t.string   "name",                     limit: 255
    t.text     "description"
    t.float    "latitude"
    t.float    "longitude"
    t.string   "address_line_one",         limit: 255
    t.string   "address_line_two",         limit: 255
    t.string   "city",                     limit: 255
    t.string   "state",                    limit: 255
    t.integer  "zip"
    t.integer  "neighborhood_id"
    t.string   "website",                  limit: 255
    t.string   "facebook_url",             limit: 255
    t.string   "delivery_website",         limit: 255
    t.string   "yelp_url",                 limit: 255
    t.string   "phone_number",             limit: 255
    t.integer  "location_category_id"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string   "image_file_name",          limit: 255
    t.string   "image_content_type",       limit: 255
    t.integer  "image_file_size"
    t.datetime "image_updated_at"
    t.string   "slug"
    t.string   "cover_image_file_name"
    t.string   "cover_image_content_type"
    t.integer  "cover_image_file_size"
    t.datetime "cover_image_updated_at"
    t.boolean  "modern",                               default: false
    t.boolean  "featured",                             default: false
  end

  create_table "mate_post_comments", force: :cascade do |t|
    t.string   "name",         limit: 255
    t.string   "email",        limit: 255
    t.string   "phone",        limit: 255
    t.string   "ip_address",   limit: 255
    t.string   "user_agent",   limit: 255
    t.integer  "agent_id"
    t.integer  "mate_post_id"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.text     "message"
  end

  create_table "mate_post_ignores", force: :cascade do |t|
    t.integer  "agent_id"
    t.integer  "mate_post_id"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "mate_post_likes", force: :cascade do |t|
    t.integer  "agent_id"
    t.integer  "mate_post_id"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "mate_post_views", force: :cascade do |t|
    t.integer  "agent_id"
    t.integer  "mate_post_id"
    t.string   "ip_address"
    t.string   "user_agent"
    t.datetime "created_at",               null: false
    t.datetime "updated_at",               null: false
    t.integer  "format",       default: 0
  end

  add_index "mate_post_views", ["agent_id"], name: "index_mate_post_views_on_agent_id", using: :btree
  add_index "mate_post_views", ["mate_post_id"], name: "index_mate_post_views_on_mate_post_id", using: :btree

  create_table "mate_posts", force: :cascade do |t|
    t.text     "description"
    t.float    "price"
    t.boolean  "cats",                           default: false
    t.boolean  "dogs",                           default: false
    t.integer  "neighborhood_id"
    t.integer  "agent_id"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string   "ip_address",         limit: 255
    t.string   "user_agent",         limit: 255
    t.datetime "when"
    t.string   "image_file_name",    limit: 255
    t.string   "image_content_type", limit: 255
    t.integer  "image_file_size"
    t.datetime "image_updated_at"
    t.boolean  "featured",                       default: false
    t.boolean  "hidden",                         default: false
    t.string   "email"
  end

  create_table "neighborhood_subscriptions", force: :cascade do |t|
    t.integer  "agent_id"
    t.integer  "neighborhood"
    t.datetime "created_at",   null: false
    t.datetime "updated_at",   null: false
  end

  create_table "neighborhoods", force: :cascade do |t|
    t.string   "name",               limit: 255
    t.string   "borough",            limit: 255
    t.string   "subway_lines",       limit: 255
    t.datetime "created_at",                                     null: false
    t.datetime "updated_at",                                     null: false
    t.string   "image_file_name",    limit: 255
    t.string   "image_content_type", limit: 255
    t.integer  "image_file_size"
    t.datetime "image_updated_at"
    t.boolean  "featured",                       default: false
    t.string   "slug",               limit: 255
    t.integer  "region_id"
    t.float    "latitude",                       default: 0.0
    t.float    "longitude",                      default: 0.0
  end

  add_index "neighborhoods", ["slug"], name: "index_neighborhoods_on_slug", using: :btree

  create_table "offices", force: :cascade do |t|
    t.string   "name"
    t.string   "address_line_one"
    t.string   "address_line_two"
    t.string   "city"
    t.string   "state"
    t.string   "zip_code"
    t.datetime "created_at",       null: false
    t.datetime "updated_at",       null: false
  end

  create_table "photos", force: :cascade do |t|
    t.datetime "created_at",                                     null: false
    t.datetime "updated_at",                                     null: false
    t.string   "image_file_name",    limit: 255
    t.string   "image_content_type", limit: 255
    t.integer  "image_file_size"
    t.datetime "image_updated_at"
    t.integer  "listing_id"
    t.boolean  "is_thumb",                       default: false
    t.boolean  "featured",                       default: false
  end

  create_table "regions", force: :cascade do |t|
    t.string   "name"
    t.boolean  "featured",           default: false
    t.datetime "created_at",                         null: false
    t.datetime "updated_at",                         null: false
    t.string   "image_file_name"
    t.string   "image_content_type"
    t.integer  "image_file_size"
    t.datetime "image_updated_at"
    t.float    "latitude"
    t.float    "longitude"
  end

  create_table "room_categories", force: :cascade do |t|
    t.string   "name",       limit: 255
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "room_post_comments", force: :cascade do |t|
    t.string   "name",         limit: 255
    t.string   "email",        limit: 255
    t.string   "phone",        limit: 255
    t.string   "ip_address",   limit: 255
    t.string   "user_agent",   limit: 255
    t.integer  "agent_id"
    t.integer  "room_post_id"
    t.text     "message"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "room_post_likes", force: :cascade do |t|
    t.integer  "agent_id"
    t.integer  "room_post_id"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "room_posts", force: :cascade do |t|
    t.text     "description"
    t.float    "price"
    t.boolean  "cats",                           default: false
    t.boolean  "dogs",                           default: false
    t.integer  "neighborhood_id"
    t.integer  "agent_id"
    t.datetime "when"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string   "ip_address",         limit: 255
    t.string   "user_agent",         limit: 255
    t.string   "image_file_name",    limit: 255
    t.string   "image_content_type", limit: 255
    t.integer  "image_file_size"
    t.datetime "image_updated_at"
    t.boolean  "hidden",                         default: false
    t.boolean  "featured",                       default: false
    t.float    "latitude"
    t.float    "longitude"
    t.string   "cross_streets",      limit: 255
    t.string   "email"
    t.string   "full_address"
  end

  create_table "rooms", force: :cascade do |t|
    t.integer  "room_category_id"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string   "picture_file_name",    limit: 255
    t.string   "picture_content_type", limit: 255
    t.integer  "picture_file_size"
    t.datetime "picture_updated_at"
    t.integer  "room_post_id"
    t.integer  "agent_id"
  end

  create_table "settings", force: :cascade do |t|
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_foreign_key "conversation_messages", "agents"
  add_foreign_key "conversation_messages", "conversations"
  add_foreign_key "conversation_participants", "agents"
  add_foreign_key "conversation_participants", "conversations"
  add_foreign_key "listing_status_changes", "agents"
  add_foreign_key "listing_status_changes", "listings"
  add_foreign_key "mate_post_views", "agents"
  add_foreign_key "mate_post_views", "mate_posts"

  create_view :agent_deposit_stats,  sql_definition: <<-SQL
      WITH normalized_deposits AS (
           SELECT deposits.sales_agent_id AS agent_id,
              deposits.id AS deposit_id,
              deposits."when" AS move_in_date,
                  CASE
                      WHEN (deposits.other_sales_agent_id IS NULL) THEN false
                      ELSE true
                  END AS is_split,
                  CASE deposits.deposit_status_id
                      WHEN 3 THEN 'Completed'::text
                      WHEN 4 THEN 'Cancelled'::text
                      ELSE 'Active'::text
                  END AS status
             FROM deposits
          UNION ALL
           SELECT deposits.other_sales_agent_id AS agent_id,
              deposits.id AS deposit_id,
              deposits."when" AS move_in_date,
                  CASE
                      WHEN (deposits.other_sales_agent_id IS NULL) THEN false
                      ELSE true
                  END AS is_split,
                  CASE deposits.deposit_status_id
                      WHEN 3 THEN 'Completed'::text
                      WHEN 4 THEN 'Cancelled'::text
                      ELSE 'Active'::text
                  END AS status
             FROM deposits
            WHERE (deposits.other_sales_agent_id IS NOT NULL)
          )
   SELECT monthly_stats.agent_id,
      monthly_stats.year,
      monthly_stats.month,
      monthly_stats.completed,
      monthly_stats.active,
      monthly_stats.cancelled,
      rank() OVER (PARTITION BY monthly_stats.year, monthly_stats.month ORDER BY monthly_stats.completed DESC, monthly_stats.active DESC, monthly_stats.cancelled) AS monthly_rank
     FROM ( SELECT normalized_deposits.agent_id,
              (date_part('year'::text, normalized_deposits.move_in_date))::integer AS year,
              (date_part('month'::text, normalized_deposits.move_in_date))::integer AS month,
              count(1) FILTER (WHERE (normalized_deposits.status = 'Completed'::text)) AS completed,
              count(1) FILTER (WHERE (normalized_deposits.status = 'Active'::text)) AS active,
              count(1) FILTER (WHERE (normalized_deposits.status = 'Cancelled'::text)) AS cancelled
             FROM normalized_deposits
            GROUP BY normalized_deposits.agent_id, ((date_part('year'::text, normalized_deposits.move_in_date))::integer), ((date_part('month'::text, normalized_deposits.move_in_date))::integer)) monthly_stats;
  SQL

  create_view :daily_active_mate_profiles,  sql_definition: <<-SQL
      WITH mate_post_days AS (
           SELECT (generate_series((date_range.start_date)::timestamp without time zone, (date_range.end_date)::timestamp without time zone, '1 day'::interval))::date AS date
             FROM ( SELECT (min(mate_posts_1.created_at))::date AS start_date,
                      ('now'::text)::date AS end_date
                     FROM mate_posts mate_posts_1) date_range
          )
   SELECT row_number() OVER (ORDER BY mate_post_days.date) AS id,
      mate_post_days.date,
      count(1) AS amount
     FROM (mate_post_days
       LEFT JOIN mate_posts ON (((mate_post_days.date >= mate_posts.created_at) AND (mate_post_days.date <= mate_posts."when"))))
    GROUP BY mate_post_days.date
    ORDER BY mate_post_days.date;
  SQL
end
