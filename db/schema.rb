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

ActiveRecord::Schema.define(version: 20150211034453) do

  create_table "active_admin_comments", force: :cascade do |t|
    t.string   "namespace"
    t.text     "body"
    t.string   "resource_id",   null: false
    t.string   "resource_type", null: false
    t.integer  "author_id"
    t.string   "author_type"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "active_admin_comments", ["author_type", "author_id"], name: "index_active_admin_comments_on_author_type_and_author_id"
  add_index "active_admin_comments", ["namespace"], name: "index_active_admin_comments_on_namespace"
  add_index "active_admin_comments", ["resource_type", "resource_id"], name: "index_active_admin_comments_on_resource_type_and_resource_id"

  create_table "admin_users", force: :cascade do |t|
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

  add_index "admin_users", ["email"], name: "index_admin_users_on_email", unique: true
  add_index "admin_users", ["reset_password_token"], name: "index_admin_users_on_reset_password_token", unique: true

  create_table "articles", force: :cascade do |t|
    t.integer  "judge_id"
    t.integer  "category_id"
    t.integer  "index"
    t.string   "title"
    t.string   "link"
    t.datetime "created_at",  null: false
    t.datetime "updated_at",  null: false
  end

  add_index "articles", ["category_id"], name: "index_articles_on_category_id"
  add_index "articles", ["judge_id"], name: "index_articles_on_judge_id"

  create_table "categories", force: :cascade do |t|
    t.integer  "index"
    t.string   "name"
    t.string   "code"
    t.datetime "created_at",       null: false
    t.datetime "updated_at",       null: false
    t.integer  "supercategory_id"
    t.integer  "superjudge_id"
    t.integer  "report_choices"
  end

  add_index "categories", ["code"], name: "index_categories_on_code"
  add_index "categories", ["supercategory_id"], name: "index_categories_on_supercategory_id"
  add_index "categories", ["superjudge_id"], name: "index_categories_on_superjudge_id"

  create_table "judges", force: :cascade do |t|
    t.integer  "index"
    t.string   "name"
    t.string   "email"
    t.boolean  "sent_mail"
    t.datetime "sent_mail_time"
    t.datetime "created_at",     null: false
    t.datetime "updated_at",     null: false
  end

  add_index "judges", ["name"], name: "index_judges_on_name"

  create_table "mappings", force: :cascade do |t|
    t.integer  "category_id"
    t.integer  "judge_id"
    t.integer  "weight"
    t.datetime "created_at",            null: false
    t.datetime "updated_at",            null: false
    t.integer  "first_choice"
    t.integer  "second_choice"
    t.string   "first_choice_comment"
    t.string   "second_choice_comment"
    t.integer  "third_choice"
    t.string   "third_choice_comment"
  end

  add_index "mappings", ["category_id"], name: "index_mappings_on_category_id"
  add_index "mappings", ["first_choice"], name: "index_mappings_on_first_choice"
  add_index "mappings", ["judge_id"], name: "index_mappings_on_judge_id"
  add_index "mappings", ["second_choice"], name: "index_mappings_on_second_choice"
  add_index "mappings", ["third_choice"], name: "index_mappings_on_third_choice"

  create_table "settings", force: :cascade do |t|
    t.string   "articles_home"
    t.string   "csv_basename"
    t.boolean  "mail_option"
    t.string   "default_email"
    t.string   "default_person"
    t.string   "email_subject"
    t.string   "category_letters"
    t.datetime "created_at",       null: false
    t.datetime "updated_at",       null: false
  end

  create_table "supercategories", force: :cascade do |t|
    t.string   "display_name"
    t.string   "instructions"
    t.datetime "created_at",   null: false
    t.datetime "updated_at",   null: false
    t.string   "letter_code"
  end

  create_table "superjudges", force: :cascade do |t|
    t.string   "name"
    t.string   "email"
    t.datetime "created_at",     null: false
    t.datetime "updated_at",     null: false
    t.boolean  "sent_mail"
    t.datetime "sent_mail_time"
  end

end
